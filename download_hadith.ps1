# NurVerse Hadith JSON Downloader
# Run this file from the root of your Flutter project.
#
# PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass
#   .\download_hadith.ps1
#
# The script downloads chapter-wise Bengali + Arabic + English hadith
# from the alQuranBD Hadith API and creates normalized JSON files in:
#   assets/hadith/

$ErrorActionPreference = "Stop"

$base = "https://alquranbd.com/api/hadith"
$outDir = Join-Path (Get-Location) "assets\hadith"

# Supported API collections.
$books = @(
    @{ Key = "bukhari";       File = "bukhari" },
    @{ Key = "muslim";        File = "muslim" },
    @{ Key = "abuDaud";       File = "abudawud" },
    @{ Key = "tirmidi";       File = "tirmidhi" },
    @{ Key = "ibnMajah";      File = "ibnmajah" },
    @{ Key = "riyadusSalihin";File = "riyadussalihin" }
)

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Get-Json($url) {
    Write-Host "GET $url" -ForegroundColor DarkGray
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    return ($response.Content | ConvertFrom-Json)
}

function Normalize-Hadith($item, $bookKey, $chapter) {
    [PSCustomObject]@{
        hadithnumber = [string]$item.hadithNo
        chapterId    = [string]$chapter.id
        bookNumber   = [string]$chapter.chSerial

        text         = [string]$item.hadithBengali
        arabic       = [string]$item.hadithArabic
        english      = [string]$item.hadithEnglish

        narrator     = [string]$item.rabiNameBn
        narratorEn   = [string]$item.rabiNameEn

        collection   = $bookKey
        reference    = "$bookKey $($item.hadithNo)"
        grade        = ""
    }
}

foreach ($book in $books) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Downloading $($book.Key)" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    try {
        $chapters = Get-Json "$base/$($book.Key)"

        if ($chapters -isnot [System.Array]) {
            $chapters = @($chapters)
        }

        $all = New-Object System.Collections.Generic.List[object]
        $chapterMeta = New-Object System.Collections.Generic.List[object]

        foreach ($chapter in $chapters) {
            $chapterNo = [string]$chapter.chSerial
            if ([string]::IsNullOrWhiteSpace($chapterNo)) {
                $chapterNo = [string]$chapter.id
            }

            Write-Host "  Chapter $chapterNo : $($chapter.nameBengali)" -ForegroundColor Yellow

            try {
                $hadiths = Get-Json "$base/$($book.Key)/$chapterNo"

                if ($hadiths -isnot [System.Array]) {
                    $hadiths = @($hadiths)
                }

                foreach ($h in $hadiths) {
                    $all.Add((Normalize-Hadith $h $book.Key $chapter))
                }

                $chapterMeta.Add(
                    [PSCustomObject]@{
                        id          = [string]$chapter.id
                        bookNumber  = [string]$chapter.chSerial
                        nameBn      = [string]$chapter.nameBengali
                        nameEn      = [string]$chapter.nameEnglish
                        nameAr      = ""
                        chapterNumber = [string]$chapter.chSerial
                    }
                )
            }
            catch {
                Write-Warning "Could not download chapter $chapterNo of $($book.Key): $($_.Exception.Message)"
            }
        }

        # One normalized combined file per collection.
        $hadithFile = Join-Path $outDir "hadith-$($book.File).json"

        $payload = [PSCustomObject]@{
            metadata = [PSCustomObject]@{
                collection = $book.Key
                source = "alQuranBD Hadith API"
                language = @("bn", "ar", "en")
                totalHadith = $all.Count
            }
            chapters = $chapterMeta
            hadiths = $all
        }

        $payload |
            ConvertTo-Json -Depth 12 |
            Set-Content -Path $hadithFile -Encoding UTF8

        Write-Host "  Saved: $hadithFile" -ForegroundColor Green
        Write-Host "  Hadiths: $($all.Count)" -ForegroundColor Green
    }
    catch {
        Write-Warning "FAILED: $($book.Key) - $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "DONE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "JSON files are in: $outDir"
Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "Add the following to pubspec.yaml:"
Write-Host ""
Write-Host "  assets:"
Write-Host "    - assets/hadith/"
Write-Host ""
