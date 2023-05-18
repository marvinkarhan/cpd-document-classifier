import 'dart:convert';
import 'dart:developer';

import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Config.dart';
import 'package:app/model/Document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BackendServiceImpl implements BackendService {
  String backendUri = "";
  static const String baseApiPath = "/api/v1";
  static const String getAllDocumentsUri = "$baseApiPath/document/all";
  static const String postDocumentUri = "$baseApiPath/document";
  static const String deleteDocumentByIdUri =
      "$baseApiPath/document/delete"; // uri param :id
  static const String queryDocumentByIdUri =
      "$baseApiPath/document/query"; // uri param :id

  void Function(String message)? onError;

  BackendServiceImpl() {
    backendUri = Config().backendUrl!;
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    http.Response res = await http
        .get(Uri.parse("$backendUri${BackendServiceImpl.getAllDocumentsUri}"));
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during document fetch, cannot get documents");
      return [];
    }
    List parsedRes = jsonDecode(res.body);
    List<Document> docs = parsedRes.map((e) => Document.fromJson(e)).toList();
    return docs;
  }

  @override
  Future<bool> postDocument(PlatformFile file) async {
    final uri = Uri.parse("$backendUri${BackendServiceImpl.postDocumentUri}");
    log("Uploading file ${file.name} to backend");
    final bytes = file.bytes!;
    var request = http.MultipartRequest("POST", uri);
    final doc = http.MultipartFile.fromBytes("file", bytes,
        filename: file.name, contentType: MediaType("application", "pdf"));
    request.files.add(doc);
    var streamedRes = await request.send();
    var res = await http.Response.fromStream(streamedRes);
    log("Status: ${res.statusCode.toString()}");
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during document upload, will be ignored");
      return false;
    }
    return true;
  }

  @override
  Future<http.Response> deleteDocumentById(String id) {
    return http.get(Uri.parse(
        "$backendUri${BackendServiceImpl.deleteDocumentByIdUri}/$id"));
  }

  @override
  Future<http.Response> queryDocumentById(String id) {
    return http.get(
        Uri.parse("$backendUri${BackendServiceImpl.queryDocumentByIdUri}/$id"));
  }

  @override
  void setOnError(void Function(String errorMessage)? onError) {
    this.onError = onError;
  }
}
