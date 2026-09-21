class MapperException<From, To> implements Exception{

  String message;

  MapperException(this.message);

  @override
  String toString() {
    return "Erro ao mapear de ${From} para ${To}: ${message}";
  }
}