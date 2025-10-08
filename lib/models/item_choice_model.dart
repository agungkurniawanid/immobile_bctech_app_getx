class ItemChoice {
  int? id;
  String? label;
  String? labelName;

  ItemChoice({this.id, this.label, this.labelName});

  // Factory constructor untuk membuat instance dari JSON (opsional)
  factory ItemChoice.fromJson(Map<String, dynamic> json) {
    return ItemChoice(
      id: json['id'],
      label: json['label'],
      labelName: json['labelname'],
    );
  }

  // Konversi ke Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {'id': id, 'label': label, 'labelname': labelName};
  }

  // Clone (optional)
  ItemChoice clone() {
    return ItemChoice(id: id, label: label, labelName: labelName);
  }
}
