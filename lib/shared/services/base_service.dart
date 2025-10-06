class BaseService {
  final String baseUrl = "http://10.0.2.2:8080/api/v1/";
  final String endpoint;

  BaseService(this.endpoint);

  String fullPath() {
    return '$baseUrl$endpoint';
  }
}