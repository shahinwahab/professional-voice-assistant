import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pro_voice_assistant/theme/pallete.dart';
import 'package:pro_voice_assistant/widgets/feature_box.dart';

class FeaturesSection extends StatelessWidget {
  final int startDelay;
  final int delayIncrement;

  const FeaturesSection({
    Key? key,
    this.startDelay = 200,
    this.delayIncrement = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideInLeft(
          child: Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 10, left: 22),
            child: const Text(
              'Our Services',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SlideInLeft(
          delay: Duration(milliseconds: startDelay),
          child: const FeatureBox(
            color: Pallete.featureBoxColor,
            headerText: 'Voice Assistant',
            descriptionText:
                'Talk with your voice & the assistant will respond with voice',
          ),
        ),
        SlideInLeft(
          delay: Duration(milliseconds: startDelay + delayIncrement),
          child: const FeatureBox(
            color: Pallete.featureBoxColor,
            headerText: 'Gemini AI',
            descriptionText: 'Advanced AI-powered responses to your questions',
          ),
        ),
        SlideInLeft(
          delay: Duration(milliseconds: startDelay + 2 * delayIncrement),
          child: const FeatureBox(
            color: Pallete.featureBoxColor,
            headerText: 'Smart Conversations',
            descriptionText:
                'Natural conversations with context-aware responses',
          ),
        ),
      ],
    );
  }
}
