import 'package:flutter/material.dart';

import 'constants.dart';
import 'icon_card.dart';

class ImageAndIcons extends StatelessWidget {
  const ImageAndIcons({
    super.key,
    required this.size,
    required this.temp,
    required this.humidity,
    required this.ldr,
    required this.soil,
  });

  final Size size;
  final String temp;
  final String humidity;
  final String ldr;
  final String soil;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.6, // Reduce height for less space
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding / 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconCard(
                    iconData: Icons.thermostat,
                    value: temp,
                    label: "Temp",
                  ),
                  IconCard(
                    iconData: Icons.water_drop,
                    value: humidity,
                    label: "Humidity",
                  ),
                  IconCard(iconData: Icons.sunny, value: ldr, label: "Light"),
                  IconCard(iconData: Icons.grass, value: soil, label: "Soil"),
                ],
              ),
            ),
          ),
          Container(
            height: size.height * 0.5,
            width: size.width * 0.65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(63),
                bottomLeft: Radius.circular(63),
              ),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 60,
                  color: kPrimaryColor.withOpacity(0.29),
                ),
              ],
              image: DecorationImage(
                alignment: Alignment.centerLeft,
                fit: BoxFit.cover,
                image: AssetImage("assets/img.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
