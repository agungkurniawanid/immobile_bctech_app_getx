class InputPallet {
  final int? id;
  final String? qtypallet;
  final String? skuno;

  InputPallet({this.id, this.qtypallet, this.skuno});

  /// Factory untuk membuat objek dari JSON
  factory InputPallet.fromJson(Map<String, dynamic> json) {
    return InputPallet(
      id: json['id'] as int?,
      qtypallet: json['qtypallet'] as String?,
      skuno: json['skuno'] as String?,
    );
  }

  /// Convert objek menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return {'id': id, 'qtypallet': qtypallet, 'skuno': skuno};
  }

  /// Clone (duplikasi objek)
  InputPallet clone() {
    return InputPallet(id: id, qtypallet: qtypallet, skuno: skuno);
  }
}
