class SurahModel {
  final int id;
  final int para;
  final String nameAr;
  final String nameBn;
  final String nameEn;
  final int totalAyah;

  const SurahModel({
    required this.id,
    required this.para,
    required this.nameAr,
    required this.nameBn,
    required this.nameEn,
    required this.totalAyah,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json["id"],
      para: json["para"],
      nameAr: json["name_ar"],
      nameBn: json["name_bn"],
      nameEn: json["name_en"],
      totalAyah: json["total_ayah"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "para": para,
      "name_ar": nameAr,
      "name_bn": nameBn,
      "name_en": nameEn,
      "total_ayah": totalAyah,
    };
  }
}
