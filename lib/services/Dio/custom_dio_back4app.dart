import 'package:agenda/services/Dio/custom_dio_back4app_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomDioBack4App {
  final _dio = Dio();

  Dio get dio => _dio;

  CustomDioBack4App() {
    _dio.options.baseUrl = dotenv.get("BASE_URL");
    _dio.options.headers["Content-Type"] = "application/json";
    _dio.interceptors.add(CustomDioBack4AppInterceptor());
  }
}
