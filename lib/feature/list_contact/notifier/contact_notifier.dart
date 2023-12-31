import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:project/data/repository/firebase_repository.dart';

import '../../../domain/enitites/contact/contact.dart';

class Step {
  Step(this.name, this.id, this.price, this.isPay, this.count,
      [this.isExpanded = false]);
  String name;
  String id;
  int price;
  bool isPay;
  int count;
  bool isExpanded;
}

@injectable
class ContactNotifier extends ChangeNotifier {
  final FirebaseRepository _firebaseRepository;
  ContactNotifier(this._firebaseRepository);

  List<Contact> _listContact = <Contact>[];
  List<Contact> get listContact => _listContact;
  bool _loadingGet = false;
  bool get loadingGet => _loadingGet;
  bool _loadingButton = false;
  bool get loadingButton => _loadingGet;
  List<Step> _listStep = [];
  List<Step> get listStep => _listStep;

  void onSelectStep(int index, bool isExpanded) {
    _listStep[index].isExpanded = !isExpanded;
    notifyListeners();
  }

  Future<void> getContacts(String paidId) async {
    _loadingGet = true;
    notifyListeners();
    try {
      final streamContacts = _firebaseRepository.getContacts(paidId);
      streamContacts.listen((event) {
        print(event.length);
        _listContact = event;
        _listStep = event
            .map((e) => Step(e.name, e.id, e.price, e.price >= 0, 4))
            .toList();
        notifyListeners();
      });
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
    _loadingGet = false;
    notifyListeners();
  }

  Future<bool> addContact(Contact contact, String paidId) async {
    _loadingButton = true;
    notifyListeners();
    try {
      await _firebaseRepository.addContact(contact, paidId);
    } catch (e) {
      log(e.toString());
      _loadingButton = false;
      return false;
    }
    _loadingButton = false;
    notifyListeners();
    return true;
  }
}
