import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/reminder.dart';

late StreamSubscription<Position> positionStream;

class AppStates extends ChangeNotifier {
  final _reminders = <Reminder>[];
  final _favoritPlaces = <Place>[];
  final _history = <Reminder>[];
  final _arrived = <Reminder>[];
  late LatLng _currentPosition;

  bool notify = true;
  bool ringing = false;
  bool listening = false;
  ThemeMode _themeMode = ThemeMode.system;

  Reminder? reminderRead(int index) {
    if (index >= _reminders.length || index < 0) return null;
    return _reminders[index];
  }

  void reminderAdd(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void reminderUpdate(Reminder reminder) {
    final index = _reminders.indexWhere((element) => element.id == reminder.id);
    if (index == -1) return;
    _reminders[index] = reminder;
    notifyListeners();
  }

  void reminderDelete(int index) {
    if (index >= _reminders.length || index < 0) return;
    _reminders.removeAt(index);
    notifyListeners();
  }

  List<Reminder> reminderAll() {
    return _reminders;
  }

  void reminderClear() {
    _reminders.clear();
  }

  void favoriteAdd(Place place) {
    _favoritPlaces.add(place);
    notifyListeners();
  }

  void favoriteDelete(int index) {
    if (index >= _favoritPlaces.length || index < 0) return;
    _favoritPlaces.removeAt(index);
    notifyListeners();
  }

  void favoriteClear() {
    _favoritPlaces.clear();
  }

  List<Place> favoriteAll() {
    return _favoritPlaces;
  }

  void historyAdd(Reminder reminder) {
    _history.add(reminder);
    notifyListeners();
  }

  void historyDelete(int index) {
    if (index >= _history.length || index < 0) return;
    _history.removeAt(index);
    notifyListeners();
  }

  void historyClear() {
    _history.clear();
  }

  List<Reminder> historyAll() {
    return _history;
  }

  void arrivedAdd(Reminder reminder) {
    _arrived.add(reminder);
    notifyListeners();
  }

  void arrivedDelete(int index) {
    if (index >= _arrived.length || index < 0) return;
    _arrived.removeAt(index);
    notifyListeners();
  }

  void arrivedClear() {
    _arrived.clear();
  }

  List<Reminder> arrivedAll() {
    return _arrived;
  }

  void setCurrent(LatLng current) {
    _currentPosition = current;
    notifyListeners();
  }

  LatLng getCurrent() {
    return _currentPosition;
  }

  void setRinging(bool state) {
    ringing = state;
    notifyListeners();
  }

  void setNotify(bool state) {
    notify = state;
    notifyListeners();
  }

  void setListening(bool state) {
    listening = state;
    notifyListeners();
  }

  void setThemeMode(ThemeMode state) {
    _themeMode = state;
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    return _themeMode;
  }
}
