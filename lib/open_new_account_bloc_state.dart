part of 'open_new_account_bloc.dart';

class OpenNewAccountBlocState extends BaseState {
  OpenNewAccountBlocState({
    this.currentStep = 0,
    this.identificationView = 0,
    this.country,
    this.countryView,
    this.isTimerRunning = true,
    this.isOTPValid = true,
    this.isValid = false,
    this.genderList = const <String>[],
    this.countryResidenceList = const <String>[],
    this.countryList = const <String>[],
    this.accountType,
    this.showUKAddressSearch = false,
  });

  final int currentStep;
  final int identificationView;
  final Country? country;
  final Country? countryView;
  final bool isOTPValid;
  final bool isValid;
  final bool isTimerRunning;
  final List<String> genderList;
  final List<String> countryResidenceList;
  final List<String> countryList;
  final int? accountType;
  final bool showUKAddressSearch;

  OpenNewAccountBlocState copyWith({
    int? currentStep,
    int? identificationView,
    Country? country,
    Country? countryView,
    bool? isValid,
    bool? isOTPValid,
    bool? isTimerRunning,
    List<String>? genderList,
    List<String>? countryResidenceList,
    List<String>? countryList,
    int? accountType,
    bool? showUKAddressSearch,
  }) {
    return OpenNewAccountBlocState(
      currentStep: currentStep ?? this.currentStep,
      countryList: countryList ?? this.countryList,
      identificationView: identificationView ?? this.identificationView,
      country: country ?? this.country,
      isOTPValid: isOTPValid ?? this.isOTPValid,
      countryView: countryView ?? this.countryView,
      isValid: isValid ?? this.isValid,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      genderList: genderList ?? this.genderList,
      countryResidenceList: countryResidenceList ?? this.countryResidenceList,
      accountType: accountType ?? this.accountType,
      showUKAddressSearch: showUKAddressSearch ?? this.showUKAddressSearch,
    );
  }
}
