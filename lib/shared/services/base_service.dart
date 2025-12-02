class BaseService {

  final String baseUrl = "https://backend-web-services-1.onrender.com/api/v1/";

  final String endpoint;

  BaseService(this.endpoint);

  String fullPath() {
    return '$baseUrl$endpoint';
  }
}