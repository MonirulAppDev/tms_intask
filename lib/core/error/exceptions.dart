class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Cache Error'});
}

class PermissionException implements Exception {
  final String message;
  PermissionException({this.message = 'Permission denied'});
}

class ConflictException implements Exception {
  final String message;
  ConflictException({this.message = 'Schedule conflict detected'});
}
