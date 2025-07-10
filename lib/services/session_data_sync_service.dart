import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/editable_drill_model.dart';
import '../models/drill_model.dart';
import 'api_service.dart';

class SessionDataSyncService {
  static final SessionDataSyncService _instance = SessionDataSyncService._internal();
  factory SessionDataSyncService() => _instance;
  SessionDataSyncService._internal();

  static SessionDataSyncService get shared => _instance;

  final ApiService _apiService = ApiService.shared;

  /// Sync the ordered session drills to the backend
  Future<bool> syncOrderedSessionDrills(List<EditableDrillModel> sessionDrills) async {
    try {
      final drillsData = sessionDrills.map((drill) => {
        'drill': {
          'uuid': drill.drill.id, // Use 'uuid' for backend compatibility
          'title': drill.drill.title
        },
        'sets_done': drill.setsDone,
        'sets': drill.totalSets,
        'reps': drill.totalReps,
        'duration': drill.totalDuration,
        'is_completed': drill.isCompleted,
      }).toList();
      
      final requestData = {'ordered_drills': drillsData};
      
      if (kDebugMode) {
        print('📤 Syncing ordered session drills: ${jsonEncode(requestData)}');
      }
      
      final response = await _apiService.put(
        '/api/sessions/ordered_drills/',
        body: requestData,
        requiresAuth: true,
      );
      
      if (response.isSuccess) {
        if (kDebugMode) {
          print('✅ Successfully synced ordered session drills');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to sync ordered session drills: ${response.statusCode} ${response.error}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing ordered session drills: $e');
      }
      return false;
    }
  }

  /// Fetch ordered session drills from the backend
  Future<List<EditableDrillModel>> fetchOrderedSessionDrills() async {
    try {
      if (kDebugMode) {
        print('📥 Fetching ordered session drills from backend');
      }

      final response = await _apiService.get(
        '/api/sessions/ordered_drills/',
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> drillsJson = response.data!['ordered_drills'] ?? response.data!;
        final drills = drillsJson.map((drillJson) {
          return EditableDrillModel.fromJson(drillJson);
        }).toList();

        if (kDebugMode) {
          print('✅ Successfully fetched ${drills.length} ordered session drills');
        }
        return drills;
      } else {
        if (kDebugMode) {
          print('❌ Failed to fetch ordered session drills: ${response.statusCode} ${response.error}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching ordered session drills: $e');
      }
      return [];
    }
  }
} 