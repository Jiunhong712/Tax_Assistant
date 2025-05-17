import 'package:flutter/material.dart';
import 'package:taxassistant/main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _hasTIN = false;
  bool _showTINQuestion = true;
  bool _showFreelancerQuestion = false;
  bool _isFreelancer = false;
  bool _isFreelanceBusiness = false;
  bool _showProceedButton = false;

  void _onTINAnswer(bool hasTIN) {
    setState(() {
      _hasTIN = hasTIN;
      _showFreelancerQuestion =
          hasTIN; // Show freelancer question only if user has TIN
      _showProceedButton =
          !hasTIN; // Show proceed button if user doesn't have TIN
    });
  }

  void _onFreelancerAnswer(bool isFreelancer) {
    setState(() {
      _isFreelancer = isFreelancer;
      if (!_isFreelancer) {
        _isFreelanceBusiness = false; // Reset if not a freelancer
        _showProceedButton = true;
      } else {
        _showProceedButton =
            false; // Hide proceed button if freelancer until business question is answered
      }
    });
  }

  void _onFreelanceBusinessAnswer(bool isBusiness) {
    setState(() {
      _isFreelanceBusiness = isBusiness;
      _showProceedButton = true;
    });
  }

  void _onProceed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Visibility(
              visible: _showTINQuestion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Do you have a Tax Identification Number (TIN)?',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            _showFreelancerQuestion || _showProceedButton
                                ? null
                                : () => _onTINAnswer(true),
                        child: const Text('Yes'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            _showFreelancerQuestion || _showProceedButton
                                ? null
                                : () => _onTINAnswer(false),
                        child: const Text('No'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: !_hasTIN && !_showTINQuestion,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'You need a TIN to proceed. Please register for one.',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement TIN registration link action
                            },
                            child: const Text('Register for TIN'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _showFreelancerQuestion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you a freelancer?',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            _showFreelancerQuestion && !_isFreelancer
                                ? () => _onFreelancerAnswer(true)
                                : null,
                        child: const Text('Yes'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            _showFreelancerQuestion && !_isFreelancer
                                ? () => _onFreelancerAnswer(false)
                                : null,
                        child: const Text('No'),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _isFreelancer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Is your freelance a business?',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed:
                                  _isFreelancer && !_showProceedButton
                                      ? () => _onFreelanceBusinessAnswer(true)
                                      : null,
                              child: const Text('Yes'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed:
                                  _isFreelancer && !_showProceedButton
                                      ? () => _onFreelanceBusinessAnswer(false)
                                      : null,
                              child: const Text('No'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _showProceedButton,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _onProceed,
                    child: const Text('Proceed'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
