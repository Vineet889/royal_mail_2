import 'package:domain/model/in_otp_generate/in_otp_generate_model.dart';
import 'package:domain/model/in_otp_verification/in_otp_verification_model.dart';
import 'package:domain/model/master/account_purpose_model.dart';
import 'package:domain/model/master/annual_salary_model.dart';
import 'package:domain/model/master/branch_model.dart';
import 'package:domain/model/master/country_model.dart';
import 'package:domain/model/master/country_residence_model.dart';
import 'package:domain/model/master/employment_status_model.dart';
import 'package:domain/model/master/fund_type_model.dart';
import 'package:domain/model/master/gender_model.dart';
import 'package:domain/model/master/reason_providing_ni_model.dart';
import 'package:domain/model/master/security_question_model.dart';
import 'package:domain/model/master/tax_residence_country_model.dart';
import 'package:domain/model/single_message/single_message_model.dart';
import 'package:domain/repository/secure_storage/secure_storage.dart';
import 'package:domain/usecase/financial_details/tax_details_uc.dart';
import 'package:domain/usecase/master/account_purpose_uc.dart';
import 'package:domain/usecase/master/account_salary_uc.dart';
import 'package:domain/usecase/master/branch_type_uc.dart';
import 'package:domain/usecase/master/country_residence_uc.dart';
import 'package:domain/usecase/master/country_type_uc.dart';
import 'package:domain/usecase/master/employment_status_uc.dart';
import 'package:domain/usecase/master/fund_type_uc.dart';
import 'package:domain/usecase/master/gender_uc.dart';
import 'package:domain/usecase/master/security_question_uc.dart';
import 'package:domain/usecase/master/tax_residence_country_uc.dart';
import 'package:domain/usecase/master/uk_reason_for_nin.dart';
import 'package:domain/usecase/open_new_account/address_details_uc.dart';
import 'package:domain/usecase/open_new_account/address_india_otp_generate_uc.dart';
import 'package:domain/usecase/open_new_account/address_india_otp_verity_uc.dart';
import 'package:domain/usecase/open_new_account/identification_details_uc.dart';
import 'package:domain/usecase/open_new_account/personal_details_uc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icici_international_common_features/icici_international_common_features.dart';
import 'package:icici_international_onboarding/src/base/base_bloc.dart';
import 'package:icici_international_onboarding/src/di/di.dart';
import 'package:icici_international_onboarding/src/utils/enums.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

part 'open_new_account_bloc_state.dart';

part 'open_new_account_event.dart';

@Injectable()
class OpenNewAccountBloc
    extends BaseBloc<OpenNewAccountEvent, OpenNewAccountBlocState> {
  OpenNewAccountBloc() : super(OpenNewAccountBlocState()) {
    on<ChangeStepEvent>((event, emit) {
      emit(state.copyWith(currentStep: event.index));
    });

    on<ChangeCountryEvent>((event, emit) {
      emit(state.copyWith(country: event.country));
    });

    on<ChangeAddressDetailsEvent>((event, emit) {
      emit(state.copyWith(countryView: event.country));
    });

    on<ChangeIdentificationViewEvent>((event, emit) {
      emit(state.copyWith(identificationView: 1));
    });

    on<ValidateFieldsEvent>((event, emit) {
      emit(state.copyWith(isValid: event.isValid));
    });

    // on<isOTPValidEvent>((event, emit) {
    //   emit(state.copyWith(isOTPValid: !state.isOTPValid));
    // });

    on<TimerEvent>((event, emit) {
      emit(state.copyWith(isTimerRunning: !state.isTimerRunning));
    });

    // on<GenderListEvent>((event, emit) {
    //   emit(state.copyWith(genderList: event.value));
    // });
    //
    // on<CountryResidenceEvent>((event, emit) {
    //   emit(state.copyWith(countryResidenceList: event.value));
    // });
    //
    // on<CountryTypeEvent>((event, emit) {
    //   emit(state.copyWith(countryList: event.value));
    // });
    _initMasterData();
    on<DataInitialize>(_onClearData);
  }

  final _genderUC = getIt<GenderUC>();
  final _countryResidenceUC = getIt<CountryResidenceUC>();
  final _countryTypeUC = getIt<CountryTypeUC>();
  final _accountPurposeUC = getIt<AccountPurposeUC>();
  final _accountSalaryUC = getIt<AccountSalaryUC>();
  final _branchTypeUC = getIt<BranchTypeUC>();
  final _employmentStatusUc = getIt<EmploymentStatusUc>();
  final _fundTypeUC = getIt<FundTypeUC>();
  final _securityQuestionUC = getIt<SecurityQuestionUC>();
  final _taxResidenceCountryUC = getIt<TaxResidenceCountryUC>();
  final _reasonProvidingNiNUC = getIt<ReasonProvidingNiNUC>();

  final FocusNode birthControllerFocusNode = FocusNode();

  final _personalDetailsUC = getIt<PersonalDetailsUseCase>();
  final _identificationDetailsUC = getIt<IdentificationDetailsUseCase>();

  // Address usecase
  final _addressDetailsUseCase = getIt<AddressDetailsUseCase>();
  final _getAddressIndiaOtpUC = getIt<GetAddressIndiaOtpUC>();
  final _addressIndiaOtpVerify = getIt<AddressIndiaOtpVerifyUC>();

  final _genderList = <String>[];
  final _countryList = <String>[];
  final _countryResidenceList = <String>[];

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final genderController = TextEditingController();
  final countryOfBirthController = TextEditingController();
  final nationalityController = TextEditingController();
  final passportNumberController = TextEditingController();
  final passportIssueDateController = TextEditingController();
  final passportExpiryController = TextEditingController();
  final countryOfResidenceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final aadhaarController = TextEditingController();
  final birthDateController = TextEditingController();
  final dateOfApplicationController = TextEditingController();
  final maritalStateController = TextEditingController();
  final titleController = TextEditingController();

  DateTime? finalDateSelected;

  // Address Details
  final otpController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final flatNameNumberController = TextEditingController();
  final houseNoController = TextEditingController();
  final houseNameController = TextEditingController();
  final streetNameController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final countryController = TextEditingController(text: 'India');

  final isOtpValid = ValueNotifier(false);
  //final String? jumioToken ;
  //final String? jumioDataCenter ;
  final ss = getIt<SecureStorage>();

  void _initMasterData() {
    apiCall<List<GenderModel>>(_genderUC).then((value) {
      if (value != null) {
        _genderList.clear();
        for (final data in value) {
          _genderList.add(data.gender);
        }
      }
    });

    apiCall<List<CountryResidenceModel>>(_countryResidenceUC).then((value) {
      if (value != null) {
        _countryResidenceList.clear();
        for (final data in value) {
          _countryResidenceList.add(data.country);
        }
      }
    });

    apiCall<List<CountryModel>>(_countryTypeUC).then((value) {
      if (value != null) {
        _countryList.clear();
        for (final data in value) {
          _countryList.add(data.country);
        }
      }
    });

    final now = DateTime.now();
    final formatter = DateFormat('dd-MMMM-yyyy');
    dateOfApplicationController.text = formatter.format(now);

    // apiCall<List<AccountPurposeModel>>(_accountPurposeUC).then((value) {
    // });
    //
    // apiCall<List<AnnualSalaryModel>>(_accountSalaryUC).then((value) {
    // });
    //
    // apiCall<List<BranchModel>>(_branchTypeUC).then((value) {
    // });
    //
    // apiCall<List<EmploymentStatusModel>>(_employmentStatusUc).then((value) {
    // });
    //
    // apiCall<List<FundTypeModel>>(_fundTypeUC).then((value) {
    // });
    //
    // apiCall<List<SecurityQuestionModel>>(_securityQuestionUC).then((value) {
    // });
    //
    // apiCall<List<TaxResidenceCountryModel>>(_taxResidenceCountryUC).then((value) {
    // });
    //
    // apiCall<List<ReasonProvidingNINoModel>>(_reasonProvidingNiNUC).then((value) {
    // });
  }

  void getAddressIndiaOtp(VoidCallback onSuccess) {
    String customerId = '';
    if (getIt.isRegistered<String>(instanceName: 'consumerId')) {
      customerId = getIt<String>(instanceName: 'consumerId');
    }
    final params = GetAddressIndiaOtpParams(
      consumerId: customerId,
      countryOfResidence: countryOfResidenceController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      aadhaarNumber: aadhaarController.text.trim().replaceAll(' ', ''),
    );
    apiCallParams<InOtpGenerateModel>(
      _getAddressIndiaOtpUC,
      params: params,
      showProgressBar: true,
      onSuccess: (s) => onSuccess(),
    );
  }

  void addressIndiaOtpVerify(VoidCallback onSuccess) {
    String customerId = '';
    if (getIt.isRegistered<String>(instanceName: 'consumerId')) {
      customerId = getIt<String>(instanceName: 'consumerId');
    }
    final params = AddressIndiaOtpVerifyParams(
      consumerId: customerId,
      otp: otpController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      aadhaarNumber: aadhaarController.text.trim().replaceAll(' ', ''),
    );

    apiCallParams<InOtpVerificationModel>(
      _addressIndiaOtpVerify,
      params: params,
      showProgressBar: true,
      onSuccess: (s) {
        if (s.uidData != null) {
          final String sd = s.uidData?.dist ?? 'sd';

          districtController.text = s.uidData?.dist ?? '';
          dateOfBirthController.text = s.uidData?.dob ?? '';
          flatNameNumberController.text = s.uidData?.loc ?? '';
          houseNameController.text = s.uidData?.lm ?? '';
          houseNoController.text = s.uidData?.house ?? '';
          streetNameController.text = s.uidData?.street ?? '';
          nameController.text = s.uidData?.name ?? '';
          cityController.text = s.uidData?.state ?? '';
          onSuccess();
        }
      },
    );
  }

  void setAddressDetails(VoidCallback onSuccess) {
    final params = AddressDetailsParams(
      name: nameController.text.trim(),
      dateOfBirth: dateOfBirthController.text.trim(),
      aadhaarNumber: aadhaarController.text.trim().convertToPlainText,
      houseNumber: houseNoController.text.trim(),
      buildingName: houseNameController.text.trim(),
      flatName: flatNameNumberController.text.trim(),
      streetName: streetNameController.text.trim(),
      city: cityController.text.trim(),
      country: countryController.text.trim(),
      district: districtController.text.trim(),
      postalCode: postalCodeController.text.trim(),
    );
    apiCallParams<SingleMessageModel>(
      _addressDetailsUseCase,
      params: params,
      showProgressBar: true,
      onSuccess: (s) => onSuccess(),
    );
  }

  void setPersonalDetails(VoidCallback onSuccess) {
    var dateValue = DateFormat('dd-MMMM-yyyy')
        .parseStrict(dateOfApplicationController.text);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateValue);
    final params = PersonalDetailsParams(
      name: nameController.text.trim(),
      surName: surnameController.text.trim(),
      gender: genderController.text.trim(),
      countryOfBirth: countryOfBirthController.text.trim(),
      nationality: nationalityController.text.trim(),
      title: titleController.text.trim(),
      dateOfApplication: formattedDate,
      maritalStatus: maritalStateController.text,
    );
    apiCallParams<SingleMessageModel>(
        _personalDetailsUC,
        params: params,
        showProgressBar: true,
        onSuccess: (s) => onSuccess(),
        onError: (error) {

        }
    );
  }

  void setIdentificationDetail(VoidCallback onSuccess) {
    final params = IdentificationDetailsParams(
      passportNumber: passportNumberController.text.trim(),
      passportIssueDate: passportIssueDateController.text.trim(),
      passportExpiryDate: passportExpiryController.text.trim(),
    );
    apiCallParams<SingleMessageModel>(
      _identificationDetailsUC,
      params: params,
      showProgressBar: true,
      onSuccess: (s) => onSuccess(),
    );
  }

  void validatePersonalDetails() {
    if (nameController.text.isNotEmpty &&
        surnameController.text.isNotEmpty &&
        genderController.text.isNotEmpty &&
        countryOfBirthController.text.isNotEmpty &&
        maritalStateController.text.isNotEmpty &&
        titleController.text.isNotEmpty &&
        birthDateController.text.isNotEmpty &&
        nationalityController.text.isNotEmpty) {
      if (!state.isValid) {
        add(ValidateFieldsEvent(isValid: true));
      }
    } else {
      if (state.isValid) {
        add(ValidateFieldsEvent(isValid: false));
      }
    }
  }

  void validateAddressDetailsStep() {
    if (countryOfResidenceController.text.toLowerCase() == 'india') {
      if (postalCodeController.text.isNotEmpty &&
          postalCodeController.text.trim().length == 6 &&
          aadhaarController.text.isNotEmpty &&
          aadhaarController.text.length == 14) {
        if (!state.isValid) {
          add(ValidateFieldsEvent(isValid: true));
        }
      } else {
        if (state.isValid) {
          add(ValidateFieldsEvent(isValid: false));
        }
      }
      return;
    } else {
      if (postalCodeController.text.isNotEmpty &&
          postalCodeController.text.trim().length == 8) {
        if (!state.isValid) {
          add(ValidateFieldsEvent(isValid: true));
        }
      } else {
        if (state.isValid) {
          add(ValidateFieldsEvent(isValid: false));
        }
      }
    }
  }

  void validateAddressDetails() {
    if (state.country == Country.uk) {
      if (_validateAddressDetailsCommon() && _validateAddressDetailsUk()) {
        if (!state.isValid) {
          add(ValidateFieldsEvent(isValid: true));
        }
      } else {
        if (state.isValid) {
          add(ValidateFieldsEvent(isValid: false));
        }
      }
    } else if (state.country == Country.india) {
      final data =
          _validateAddressDetailsCommon() && _validateAddressDetailsIndia();
      if (data) {
        if (!state.isValid) {
          add(ValidateFieldsEvent(isValid: true));
        }
      } else {
        if (state.isValid) {
          add(ValidateFieldsEvent(isValid: false));
        }
      }
    }
  }

  bool _validateAddressDetailsUk() {
    if (postalCodeController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _validateAddressDetailsIndia() {
    if (nameController.text.isNotEmpty &&
        countryOfBirthController.text.isNotEmpty &&
        aadhaarController.text.isNotEmpty &&
        postalCodeController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _validateAddressDetailsCommon() {
    if (flatNameNumberController.text.isNotEmpty &&
        houseNoController.text.isNotEmpty &&
        houseNameController.text.isNotEmpty &&
        streetNameController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        districtController.text.isNotEmpty &&
        countryController.text.isNotEmpty &&
        postalCodeController.text.trim().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void clearAddressDetails() {
    postalCodeController.clear();
    aadhaarController.clear();
  }

  void _onClearData(
      DataInitialize event,
      Emitter<OpenNewAccountBlocState> emit,
      ) {
    titleController.clear();
    nameController.clear();
    surnameController.clear();
    genderController.clear();
    countryOfBirthController.clear();
    nationalityController.clear();
    passportNumberController.clear();
    passportIssueDateController.clear();
    passportExpiryController.clear();
    countryOfResidenceController.clear();
    postalCodeController.clear();
    aadhaarController.clear();

    dateOfBirthController.clear();
    flatNameNumberController.clear();
    houseNoController.clear();
    houseNameController.clear();
    streetNameController.clear();
    cityController.clear();
    districtController.clear();
    countryController.clear();
    postalCodeController.clear();

    emit(OpenNewAccountBlocState());

    emit(state.copyWith(countryList: _countryList));
    emit(state.copyWith(genderList: _genderList));
    emit(state.copyWith(countryResidenceList: _countryResidenceList));
  }

  void updateJumio() {
    passportNumberController.text = 'AOIFE88321A';
    passportIssueDateController.text = 'Jan 12 ‘19';
    passportExpiryController.text = 'Jan 12 ‘19';

    add(ChangeIdentificationViewEvent());
  }

  @override
  Future<void> close() {
    titleController.dispose();
    nameController.dispose();
    surnameController.dispose();
    genderController.dispose();
    countryOfBirthController.dispose();
    nationalityController.dispose();
    passportNumberController.dispose();
    passportIssueDateController.dispose();
    passportExpiryController.dispose();
    countryOfResidenceController.dispose();
    postalCodeController.dispose();
    aadhaarController.dispose();
    dateOfBirthController.dispose();
    flatNameNumberController.dispose();
    houseNoController.dispose();
    houseNameController.dispose();
    streetNameController.dispose();
    cityController.dispose();
    districtController.dispose();
    countryController.dispose();
    return super.close();
  }

  void changeAccountType(int? value) {
    emit(state.copyWith(accountType: value));
  }

  void clearSecureStorage() {
    ss.clear();
  }
}
