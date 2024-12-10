import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icici_international_common_features/icici_international_common_features.dart';
import 'package:icici_international_onboarding/src/features/open_new_account/bloc/open_new_account_bloc.dart';
import 'package:icici_international_onboarding/src/features/open_new_account/widgets/verification_otp_bottomsheet.dart';
import 'package:icici_international_onboarding/src/my_app/routes/app_route_constants.dart';
import 'package:icici_international_onboarding/src/utils/enums.dart';
import 'package:icici_international_onboarding/src/utils/extension/extensions.dart';
import 'package:icici_international_onboarding/src/widgets/stepper/custom_stepper.dart';
import 'dart:html' as html;

 String receivedMessage = "";



class AddressDetailsPage extends StatelessWidget {
  const AddressDetailsPage({required this.bloc, required this.gKey, super.key});

  final OpenNewAccountBloc bloc;
  final GlobalKey<CustomStepperState> gKey;



  @override
  Widget build(BuildContext context) {
    bloc.countryController.text = 'India';
    return BlocBuilder<OpenNewAccountBloc, OpenNewAccountBlocState>(
      bloc: bloc,
      builder: (context, state) {
        if (state.countryView == null) {
          return _buildAddressDetailsMainView(context, state);
        } else if (state.countryView == Country.india) {
          return _buildAddressDetailsIndiaView(context, state);
        } else {
          return _buildAddressDetailsUkView(context, state);
        }
      },
    );
  }

  Widget _buildAddressDetailsMainView(
    BuildContext context,
    OpenNewAccountBlocState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ExpandableColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdownField(
            controller: bloc.countryOfResidenceController,
            labelText: context.ln.countryOfResidence,
            items: state.countryResidenceList,
            onChanged: (country, _) {
              bloc
                ..clearAddressDetails()
                ..validateAddressDetailsStep();
              final String countryString = country as String;
              final Country item;
              if (countryString.toLowerCase() == 'india') {
                item = Country.india;
              } else {
                item = Country.uk;
              }
              bloc.add(ChangeCountryEvent(country: item));
            },
            screenPadding: 16,
          ),
          if (state.country == Country.india) ..._buildSubIndiaView(context),
          if (state.country == Country.uk) ..._buildSubUkView(context),
          const Spacer(),
          CustomElevatedButton(
            buttonText: state.country == Country.uk
                ? context.ln.continue_t
                : context.ln.sendOtp,
            borderRadius: 16,
            disabledTextColor: AppColors.grey110,
            fontWeight: FontWeight.w600,
            letterSpacing: .25,
            textColor: AppColors.white,
            onPressed: state.isValid
                ? () {
              context.pushNamed(AppRoute.financialScreen.name);
                    // if (state.country == Country.india) {
                    //   bloc.getAddressIndiaOtp(() {
                    //     bloc.otpController.clear();
                    //     AppBottomSheet.show(
                    //       context,
                    //       VerificationOtpBottomSheet(
                    //         bloc: bloc,
                    //       ),
                    //       isScrollControlled: true,
                    //       isDismissible: false,
                    //     );
                    //   });
                    // }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubIndiaView(BuildContext context) {
    return [
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.postalCodeController,
        labelText: context.ln.postalCode,
        maxLength: 6,
        keyboardType: TextInputType.number,
        onChanged: (_) => bloc.validateAddressDetailsStep(),
      ),
      const SizedBox(height: 12),
      Text(
        context.ln.pleaseEnterPostalCodeAsPerYourAadhaarCard,
        style: context.style.labelLargeMedium.copyWith(
          color: AppColors.grey110,
        ),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.aadhaarController,
        labelText: context.ln.enterYourAadhaarNumber,
        onChanged: (_) => bloc.validateAddressDetailsStep(),
        maxLength: 14,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          MaskedTextInputFormatter(),
        ],
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
      Text(
        context.ln.weWillSendYouAnOTPOnTheMobileNumberLinkedWithYourAadhaarCard,
        style: context.style.labelLargeMedium.copyWith(
          color: AppColors.grey110,
        ),
      ),
    ];
  }

  List<Widget> _buildSubUkView(BuildContext context) {
    return [
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.postalCodeController,
        labelText: context.ln.postalCode,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z ]')),
          MaskedTextInputFormatter(),
        ],
        onChanged: (_) => bloc.validateAddressDetailsStep(),
        maxLength: 8,
      ),
    ];
  }

  Widget _buildAddressDetailsUkView(
    BuildContext context,
    OpenNewAccountBlocState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpandableColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ..._buildCommonIndUkView(context),
          Flexible( // Or SizedBox with a defined height
            child: ConstrainedBox( // Optional: To limit maximum height
              constraints: BoxConstraints(maxHeight: 150), // Example maxHeight
              child: Expanded(
                child: HtmlElementView(viewType: 'webview-html'),
              ),
            ),
          ),
          // CustomTextField(
          //   controller: bloc.postalCodeController,
          //   labelText: context.ln.postalCode,
          //   textCapitalization: TextCapitalization.words,
          //   inputFormatters: [
          //     FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z ]')),
          //   ],
          //   onChanged: (_) => bloc.validateAddressDetails(),
          // ),
          const SizedBox(height: 24),
          const Spacer(),
          CustomElevatedButton(
            buttonText: context.ln.continue_t,
            borderRadius: 16,
            disabledTextColor: AppColors.grey110,
            fontWeight: FontWeight.w600,
            letterSpacing: .25,
            textColor: AppColors.white,
            onPressed:(){
              context.goNamed(AppRoute.financialScreen.path);
            },
            // state.isValid
            //     ? () => context.goNamed(
            //           AppRoute.financialScreen.path,
            //         )
            //     : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsIndiaView(
    BuildContext context,
    OpenNewAccountBlocState state,
  ) {
    bloc.validateAddressDetails();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpandableColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomTextField(
            controller: bloc.nameController,
            labelText: context.ln.name,
            onChanged: (_) => bloc.validateAddressDetails(),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: bloc.dateOfBirthController,
            labelText: context.ln.dateOfBirth,
            onChanged: (_) => bloc.validateAddressDetails(),
            isSpecialAllowed: true,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: bloc.aadhaarController,
            labelText: context.ln.aadhaarNumber,
            onChanged: (_) => bloc.validateAddressDetails(),
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              MaskedTextInputFormatter(),
            ],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ..._buildCommonIndUkView(context),
          CustomTextField(
            controller: bloc.postalCodeController,
            labelText: context.ln.postcode,
            onChanged: (_) => bloc.validateAddressDetails(),
          ),
          const SizedBox(height: 24),
          const Spacer(),
          CustomElevatedButton(
            buttonText: context.ln.continue_t,
            borderRadius: 16,
            disabledTextColor: AppColors.grey110,
            fontWeight: FontWeight.w600,
            letterSpacing: .25,
            textColor: AppColors.white,
            onPressed: () {
              context.goNamed(AppRoute.financialScreen.path);
            },
            // onPressed: state.isValid
            //     ? () {
            //         // bloc.setAddressDetails(() {
            //         context.goNamed(AppRoute.financialScreen.path);
            //         // });
            //       }
            //     : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildCommonIndUkView(BuildContext context) {
    return [
      CustomTextField(
        controller: bloc.flatNameNumberController,
        labelText: context.ln.flatNameNumber,
        onChanged: (_) => bloc.validateAddressDetails(),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.houseNoController,
        labelText: context.ln.houseNumber,
        onChanged: (_) => bloc.validateAddressDetails(),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.houseNameController,
        labelText: context.ln.houseBuildingName,
        onChanged: (_) => bloc.validateAddressDetails(),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.streetNameController,
        labelText: context.ln.streetName,
        onChanged: (_) => bloc.validateAddressDetails(),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.cityController,
        labelText: context.ln.cityTown,
        onChanged: (_) => bloc.validateAddressDetails(),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.districtController,
        labelText: context.ln.district,
        onChanged: (_) => bloc.validateAddressDetails(),
      ),
      const SizedBox(height: 20),
      CustomTextField(
        controller: bloc.countryController,
        labelText: context.ln.country,
        disabledColor: AppColors.grey61,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.grey70),
        ),
        enabled: false,
      ),
      const SizedBox(height: 20),
    ];
  }
}
