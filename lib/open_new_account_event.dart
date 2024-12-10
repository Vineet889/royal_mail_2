part of 'open_new_account_bloc.dart';

@immutable
abstract class OpenNewAccountEvent extends BaseEvent {}

class ChangeStepEvent extends OpenNewAccountEvent {
  ChangeStepEvent({required this.index});

  final int index;
}

class ChangeCountryEvent extends OpenNewAccountEvent {
  ChangeCountryEvent({required this.country});

  final Country country;
}

class ChangeAddressDetailsEvent extends OpenNewAccountEvent {
  ChangeAddressDetailsEvent({required this.country});

  final Country country;
}

class ChangeIdentificationViewEvent extends OpenNewAccountEvent {}

class ValidateFieldsEvent extends OpenNewAccountEvent {
  ValidateFieldsEvent({required this.isValid});

  final bool isValid;
}

class TimerEvent extends OpenNewAccountEvent {}

class DataInitialize extends OpenNewAccountEvent {}

class ChangeAccountTypeEvent extends OpenNewAccountEvent {
  ChangeAccountTypeEvent({required this.value});

  final int value;
}

// class GenderListEvent extends CurrentAccountEvent {
//   GenderListEvent(this.value);
//
//   final List<String> value;
// }
//
// class CountryResidenceEvent extends CurrentAccountEvent {
//   CountryResidenceEvent(this.value);
//
//   final List<String> value;
// }
//
// class CountryTypeEvent extends CurrentAccountEvent {
//   CountryTypeEvent(this.value);
//
//   final List<String> value;
// }
