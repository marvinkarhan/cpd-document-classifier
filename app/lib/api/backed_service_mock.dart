
import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Document.dart';
import 'package:file_picker/file_picker.dart';

class BackendServiceMock implements BackendService {
  final Document _mockDoc1 = Document(id: "mockId1", title: "mockTitle1", content: "mockContent1", distance: 80, certainty: 69);
  final Document _mockDoc2 = Document(id: "mockId2", title: "mockTitle2", content: "mockContent2", distance: 70, certainty: 59);
  final Document _mockDoc3 = Document(id: "mockId3", title: "mockTitle3", content: "mockContent3", distance: 60, certainty: 49);
  List<Document> store = [];
  void Function(String message)? onError;

  BackendServiceMock() {
    store.add(_mockDoc1);
    store.add(_mockDoc2);
    store.add(_mockDoc3);
  }
  @override
  Future<bool> deleteDocumentById(String id) async {
    for (var element in store) {
      if (element.id == id) {
        return store.remove(element);
      }
    }
    return false;
  }

  @override
  Future<String> downloadDocumentById(String id) async {
    return "/$id";
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    return store;
  }

  @override
  Future<bool> postDocument(PlatformFile file) async {
    double nr = store.length + 1;
    Document newDoc = Document(id: "mockId$nr", title: "mockTitle$nr", content: "mockContent$nr", distance: 10 + nr, certainty: 10 + nr);
    store.add(newDoc);
    return true;
  }

  @override
  Future<List<Document>> queryDocumentById(String id) async {
    List<Document> mockDocuments = [];
    mockDocuments = await getAllDocuments();
    for (var element in mockDocuments) {
      element.distance = element.distance! - 10;
      element.certainty = element.certainty! - 10;
    }
    return mockDocuments;
  }

  @override
  void setOnError(void Function(String errorMessage)? onError) {
    this.onError = onError;
  }

}