import 'package:agenda/models/contato_model.dart';
import 'package:agenda/services/Dio/custom_dio_back4app.dart';

class Back4AppService {
  final CustomDioBack4App _customDioBack4App = CustomDioBack4App();
  final _url = "Contato";

  Future<ContatoModel> get(String? objectId) async {
    try {
      var contatoModel = ContatoModel([]);
      var url = _url;
      if (objectId != null && objectId.isNotEmpty) {
        url = "$url?where={\"objectId\":\"$objectId\"}";
      }
      var result = await _customDioBack4App.dio.get(url);

      if (result.statusCode == 200) {
        contatoModel = ContatoModel.fromJson(result.data);
      }

      return contatoModel;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> post(Contato contato) async {
    try {
      var body = contato.toJsonCreate();
      await _customDioBack4App.dio.post(_url, data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> put(Contato contato) async {
    try {
      var url = "$_url/${contato.objectId}";
      var body = contato.toJsonCreate();
      await _customDioBack4App.dio.put(url, data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      var url = "$_url/$id";
      await _customDioBack4App.dio.delete(url);
    } catch (e) {
      rethrow;
    }
  }
}
