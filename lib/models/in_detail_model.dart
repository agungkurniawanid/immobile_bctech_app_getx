class InDetail {
  String? bstme;
  String? descr;
  String? ebeln;
  String? ebelp;
  String? flag;
  String? group;
  String? hsdat;
  String? maktx;
  String? matnr;
  String? mectn;
  String? meins;
  double? menge;
  String? meuom;
  int? qtctn;
  double? qtuom;
  int? pallet;
  int? umrez;
  String? vfdat;
  String? image;
  double? grqty;
  double? poqtyori;
  String? pounitori;
  double? qtyavail;
  String? barcode;
  int? poqtyctn;
  String? pounitctn;
  String? updatedByUsername;
  String? updated;
  String? cloned;
  String? appUser;
  String? appVersion;

  InDetail({
    this.bstme,
    this.descr,
    this.ebeln,
    this.ebelp,
    this.flag,
    this.group,
    this.hsdat,
    this.maktx,
    this.matnr,
    this.mectn,
    this.meins,
    this.menge,
    this.meuom,
    this.qtctn,
    this.qtuom,
    this.pallet,
    this.umrez,
    this.vfdat,
    this.image,
    this.grqty,
    this.poqtyori,
    this.pounitori,
    this.qtyavail,
    this.barcode,
    this.poqtyctn,
    this.pounitctn,
    this.updatedByUsername,
    this.updated,
    this.cloned,
    this.appUser,
    this.appVersion,
  });

  /// ✅ Konversi ke Map untuk Firestore atau JSON
  Map<String, dynamic> toMap() {
    return {
      'BSTME': bstme,
      'DESCR': descr,
      'EBELN': ebeln,
      'EBELP': ebelp,
      'FLAG': flag,
      'GROUP': group,
      'HSDAT': hsdat,
      'MAKTX': maktx,
      'MATNR': matnr,
      'MECTN': mectn,
      'MEINS': meins,
      'MENGE': menge ?? 0.0,
      'MEUOM': meuom,
      'QTCTN': qtctn ?? 0,
      'QTUOM': qtuom ?? 0.0,
      'PALLET': pallet ?? 0,
      'UMREZ': umrez ?? 0,
      'VFDAT': vfdat,
      'IMAGE': image,
      'GR_QTY': grqty ?? 0.0,
      'POQTY_ORI': poqtyori ?? 0.0,
      'POUNIT_ORI': pounitori,
      'QTY_AVAIL': qtyavail ?? 0.0,
      'BARCODE': barcode,
      'POQTY_CTN': poqtyctn ?? 0,
      'POUNIT_CTN': pounitctn,
      'UPDATEDBYUSERNAME': updatedByUsername,
      'UPDATED': updated,
      'CLONE': cloned,
      'APP_USER': appUser,
      'APP_VERSION': appVersion,
    };
  }

  /// ✅ Alias untuk kompatibilitas dengan model lain
  Map<String, dynamic> toJson() => toMap();

  /// ✅ Factory untuk membuat objek dari JSON
  factory InDetail.fromJson(Map<String, dynamic> data) {
    return InDetail(
      bstme: data['BSTME']?.toString() ?? '',
      descr: data['DESCR']?.toString() ?? '',
      ebeln: data['EBELN']?.toString() ?? '',
      ebelp: data['EBELP']?.toString() ?? '',
      flag: data['FLAG']?.toString() ?? '',
      group: data['GROUP']?.toString() ?? '',
      hsdat: data['HSDAT']?.toString() ?? '',
      maktx: data['MAKTX']?.toString() ?? '',
      matnr: data['MATNR']?.toString() ?? '',
      mectn: data['MECTN']?.toString() ?? '',
      meins: data['MEINS']?.toString() ?? '',
      menge: (data['MENGE'] is num) ? (data['MENGE'] as num).toDouble() : 0.0,
      meuom: data['MEUOM']?.toString() ?? '',
      qtctn: data['QTCTN'] is int
          ? data['QTCTN']
          : int.tryParse('${data['QTCTN'] ?? 0}') ?? 0,
      qtuom: (data['QTUOM'] is num) ? (data['QTUOM'] as num).toDouble() : 0.0,
      pallet: data['PALLET'] is int
          ? data['PALLET']
          : int.tryParse('${data['PALLET'] ?? 0}') ?? 0,
      umrez: data['UMREZ'] is int
          ? data['UMREZ']
          : int.tryParse('${data['UMREZ'] ?? 0}') ?? 0,
      vfdat: data['VFDAT']?.toString() ?? '',
      image: data['IMAGE']?.toString() ?? '',
      grqty: (data['GR_QTY'] is num) ? (data['GR_QTY'] as num).toDouble() : 0.0,
      poqtyori: (data['POQTY_ORI'] is num)
          ? (data['POQTY_ORI'] as num).toDouble()
          : 0.0,
      pounitori: data['POUNIT_ORI']?.toString() ?? '',
      qtyavail: (data['QTY_AVAIL'] is num)
          ? (data['QTY_AVAIL'] as num).toDouble()
          : 0.0,
      barcode: data['BARCODE']?.toString() ?? '',
      poqtyctn: data['POQTY_CTN'] is int
          ? data['POQTY_CTN']
          : int.tryParse('${data['POQTY_CTN'] ?? 0}') ?? 0,
      pounitctn: data['POUNIT_CTN']?.toString() ?? '',
      updatedByUsername: data['UPDATEDBYUSERNAME']?.toString() ?? '',
      updated: data['UPDATED']?.toString() ?? '',
      cloned: data['CLONE']?.toString() ?? '',
      appUser: data['APP_USER']?.toString() ?? '',
      appVersion: data['APP_VERSION']?.toString() ?? '',
    );
  }

  /// ✅ Clone object agar data aman dari referensi langsung
  InDetail.clone(InDetail data) {
    bstme = data.bstme;
    descr = data.descr;
    ebeln = data.ebeln;
    ebelp = data.ebelp;
    flag = data.flag;
    group = data.group;
    hsdat = data.hsdat;
    maktx = data.maktx;
    matnr = data.matnr;
    mectn = data.mectn;
    meins = data.meins;
    menge = data.menge;
    meuom = data.meuom;
    qtctn = data.qtctn;
    qtuom = data.qtuom;
    pallet = data.pallet;
    umrez = data.umrez;
    vfdat = data.vfdat;
    image = data.image;
    grqty = data.grqty;
    poqtyori = data.poqtyori;
    pounitori = data.pounitori;
    qtyavail = data.qtyavail;
    barcode = data.barcode;
    poqtyctn = data.poqtyctn;
    pounitctn = data.pounitctn;
    updatedByUsername = data.updatedByUsername;
    updated = data.updated;
    cloned = data.cloned;
    appUser = data.appUser;
    appVersion = data.appVersion;
  }

  /// ✅ Metode helper untuk menggandakan object
  InDetail clone() => InDetail.clone(this);
}
