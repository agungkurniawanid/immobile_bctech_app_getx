import 'dart:convert';

class RequestWorkflow {
  final int? userid;
  final String? email;
  final String? password;
  final String? role;
  final String? documentno;
  final String? group;
  final String? token;
  final String? username;
  final String? lGORT;

  RequestWorkflow({
    this.userid,
    this.email,
    this.password,
    this.role,
    this.documentno,
    this.group,
    this.token,
    this.username,
    this.lGORT,
  });

  // ----------------- JSON Builders -----------------

  Map<String, dynamic> toJsonLogin() => {"email": email, "password": password};

  Map<String, dynamic> toJsonEmail() => {"documentno": documentno};

  Map<String, dynamic> toJsonApproveIn() => {
    "group": group,
    "ebeln": documentno,
    "all": role,
  };

  Map<String, dynamic> toJsonSaveNoDocument() => {
    "username": username,
    "ebeln": documentno,
  };

  Map<String, dynamic> toJsonGetDocument() => {"ebeln": documentno};

  Map<String, dynamic> toJsonGetStock() => {"LGORT": lGORT};

  Map<String, dynamic> toJsonApproveSR() => {
    "documentno": documentno,
    "group": group,
  };

  Map<String, dynamic> toJsonRefreshStock() => {
    "werks": group,
    "lgort": documentno,
    "username": username,
  };

  Map<String, dynamic> toAuth() => {"Authorization": token};

  Map<String, dynamic> toJsonCategory() => {"userid": userid, "role": role};

  // ----------------- Optional: fromJson (kalau dibutuhkan) -----------------
  factory RequestWorkflow.fromJson(Map<String, dynamic> json) =>
      RequestWorkflow(
        userid: json['userid'],
        email: json['email'],
        password: json['password'],
        role: json['role'],
        documentno: json['documentno'],
        group: json['group'],
        token: json['token'],
        username: json['username'],
        lGORT: json['LGORT'],
      );
}

// ----------------- JSON Encode Helper Functions -----------------

String toJsonLogin(RequestWorkflow data) => json.encode(data.toJsonLogin());

String toJsonEmail(RequestWorkflow data) => json.encode(data.toJsonEmail());

String toAuth(RequestWorkflow data) => json.encode(data.toAuth());

String toJsonApproveSR(RequestWorkflow data) =>
    json.encode(data.toJsonApproveSR());

String toJsonRefreshStock(RequestWorkflow data) =>
    json.encode(data.toJsonRefreshStock());

String toJsonApproveIn(RequestWorkflow data) =>
    json.encode(data.toJsonApproveIn());

String toJsonSaveNoDocument(RequestWorkflow data) =>
    json.encode(data.toJsonSaveNoDocument());

String toJsonGetStock(RequestWorkflow data) =>
    json.encode(data.toJsonGetStock());

String toJsonGetDocument(RequestWorkflow data) =>
    json.encode(data.toJsonGetDocument());

String toJsonCategory(RequestWorkflow data) =>
    json.encode(data.toJsonCategory());
