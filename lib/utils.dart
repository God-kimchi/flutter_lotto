import 'package:flutter/material.dart';

Color lottoColor1to10 = const Color.fromARGB(255, 251, 196, 0);
Color lottoColor11to20 = const Color.fromARGB(255, 105, 200, 242);
Color lottoColor21to30 = const Color.fromARGB(255, 255, 114, 114);
Color lottoColor31to40 = const Color.fromARGB(255, 170, 170, 170);
Color lottoColor41to45 = const Color.fromARGB(255, 176, 216, 64);

Color makeLottoBallColor(int number) {
  if (number < 11) {
    return lottoColor1to10;
  } else if (number < 21) {
    return lottoColor11to20;
  } else if (number < 31) {
    return lottoColor21to30;
  } else if (number < 41) {
    return lottoColor31to40;
  } else {
    return lottoColor41to45;
  }
}
