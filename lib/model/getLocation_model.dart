// To parse this JSON data, do
//
//     final responseModel1 = responseModel1FromJson(jsonString);

import 'dart:convert';

List<GetLocationModel> responseModel1FromJson(String str) =>
    List<GetLocationModel>.from(
        json.decode(str).map((x) => GetLocationModel.fromJson(x)));

String responseModel1ToJson(List<GetLocationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLocationModel {
  String id;
  String tcstpic;
  String tlatval;
  String tlngval;

  GetLocationModel({
    required this.id,
    required this.tcstpic,
    required this.tlatval,
    required this.tlngval,
  });

  factory GetLocationModel.fromJson(Map<String, dynamic> json) => GetLocationModel(
        id: json["id"],
        tcstpic: json["tcstpic"],
        tlatval: json["tlatval"],
        tlngval: json["tlngval"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tcstpic": tcstpic,
        "tlatval": tlatval,
        "tlngval": tlngval,
      };
}
