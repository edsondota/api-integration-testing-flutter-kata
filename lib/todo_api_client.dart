library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:api_testing_flutter_kata/exceptions/todo_api_client_exceptions.dart';
import 'package:api_testing_flutter_kata/model/task.dart';
import 'package:http/http.dart' as http;

class TodoApiClient {
  final String _baseAddress;

  TodoApiClient(this._baseAddress);

  Future<List<Task>> getAllTasks() async {
    final response = await _get('/todos');

    final decodedTasks = json.decode(response.body) as List;

    return decodedTasks.map((jsonTask) => Task.fromJson(jsonTask)).toList();
  }

  Future<Task> getTasksById(String id) async {
    final response = await _get('/todos/$id');

    return Task.fromJson(json.decode(response.body));
  }

  Future<Task> addTask(Task task) async {
    final response = await _post(task);

    return Task.fromJson(json.decode(response.body));
  }

  Future<Task> updateTask(Task task) async {
    final response = await _put(task);

    return Task.fromJson(json.decode(response.body));
  }

  Future<void> deleteTaskById(String id) async {
    await _delete(id);
  }

  Future<http.Response> _get(String endpoint) async {
    try {
      final response = await http.get(
        '$_baseAddress$endpoint',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException catch (e) {
      print(e.toString());
      throw NetworkException();
    }
  }

  Future<http.Response> _post(Task task) async {
    try {
      final response = await http.post(
        '$_baseAddress/todos',
        body: json.encode(task.toJson()) ,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http.Response> _put(Task task) async {
    try {
      final response = await http.put(
        '$_baseAddress/todos/${task.id}',
        body: json.encode(task.toJson()) ,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException  {
      throw NetworkException();
    }
  }

  Future<http.Response> _delete(String id) async {
    try {
      final response = await http.delete(
        '$_baseAddress/todos/$id',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException  {
      throw NetworkException();
    }
  }

  http.Response returnResponseOrThrowException(http.Response response) {
    if (response.statusCode == 404) {
      throw ItemNotFoundException();
    } else if (response.statusCode > 400) {
      throw UnKnowApiException(response.statusCode);
    } else {
      return response;
    }
  }
}
