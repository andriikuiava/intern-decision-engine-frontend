import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inbank_frontend/fonts.dart';
import 'package:inbank_frontend/widgets/national_id_field.dart';

import '../api_service.dart';
import '../colors.dart';

class LoanForm extends StatefulWidget {
  const LoanForm({Key? key}) : super(key: key);

  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  String _nationalId = '';
  int _loanAmount = 2500;
  int _loanPeriod = 36;
  int _loanAmountResult = 0;
  int _loanPeriodResult = 0;
  String _errorMessage = '';
  String _country = 'Estonia'; // Default country

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final result = await _apiService.requestLoanDecision(
          _nationalId, _loanAmount, _loanPeriod, _country);
      setState(() {
        int tempAmount = int.parse(result['loanAmount'].toString());
        int tempPeriod = int.parse(result['loanPeriod'].toString());

        if (tempAmount <= _loanAmount || tempPeriod > _loanPeriod) {
          _loanAmountResult = tempAmount;
          _loanPeriodResult = tempPeriod;
        } else {
          _loanAmountResult = _loanAmount;
          _loanPeriodResult = _loanPeriod;
        }
        _errorMessage = result['errorMessage'].toString();
      });
    } else {
      _loanAmountResult = 0;
      _loanPeriodResult = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth / 3;
    const minWidth = 500.0;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: max(minWidth, formWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  NationalIdTextFormField(
                    onChanged: (value) {
                      setState(() {
                        _nationalId = value ?? '';
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),
                  DropdownButtonFormField<String>(
                    value: _country,
                    decoration: const InputDecoration(
                      labelText: 'Select Country',
                      labelStyle: TextStyle(color: AppColors.primaryColor),
                    ),
                    dropdownColor: AppColors.primaryColor,
                    items: ['Estonia', 'Latvia', 'Lithuania']
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country, style: TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _country = value!;
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Text('Loan Amount: $_loanAmount €'),
                  Slider.adaptive(
                    value: _loanAmount.toDouble(),
                    min: 2000,
                    max: 10000,
                    divisions: 80,
                    label: '$_loanAmount €',
                    activeColor: AppColors.secondaryColor,
                    onChanged: (double newValue) {
                      setState(() {
                        _loanAmount = ((newValue.floor() / 100).round() * 100);
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Text('Loan Period: $_loanPeriod months'),
                  Slider.adaptive(
                    value: _loanPeriod.toDouble(),
                    min: 12,
                    max: 48,
                    divisions: 40,
                    label: '$_loanPeriod months',
                    activeColor: AppColors.secondaryColor,
                    onChanged: (double newValue) {
                      setState(() {
                        _loanPeriod = ((newValue.floor() / 6).round() * 6);
                        _submitForm();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                  'Approved Loan Amount: ${_loanAmountResult != 0 ? _loanAmountResult : "--"} €'),
              const SizedBox(height: 8.0),
              Text(
                  'Approved Loan Period: ${_loanPeriodResult != 0 ? _loanPeriodResult : "--"} months'),
              Visibility(
                  visible: _errorMessage != '',
                  child: Text(_errorMessage, style: errorMedium))
            ],
          ),
        ],
      ),
    );
  }
}