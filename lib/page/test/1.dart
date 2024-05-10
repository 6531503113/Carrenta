import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatefulWidget {
  @override
  _QRGeneratorPageState createState() => _QRGeneratorPageState();
}

class QRPPGEN {
  int calculateCRC(String payload) {
    int crc = 0xFFFF;
    int polynomial = 0x1021;

    List<int> bytes = payload.codeUnits;

    for (int byte in bytes) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ polynomial) & 0xFFFF;
        } else {
          crc <<= 1;
        }
      }
    }

    return crc & 0xFFFF;
  }

  String generateQRCodeData(int amount) {
    int num = 0;
    if (amount >= 1000) {
      num = 7;
    } else if (amount >= 100) {
      num = 6;
    } else if (amount >= 10) {
      num = 5;
    } else if (amount >= 1) {
      num = 4;
    }
    String payload =
        "00020101021229370016A000000677010111021309930001518365802TH5303764540$num$amount.006304";

    int crc = calculateCRC(payload);
    String crcHex = crc.toRadixString(16).toUpperCase();
    // Pad with leading zeros if necessary to ensure the CRC is 4 digits long
    crcHex = crcHex.padLeft(4, '0');

    String qrCodeData = payload + crcHex;
    return qrCodeData;
  }
}

void main() {
  int amount = 400;
  QRPPGEN qrGenerator = QRPPGEN();
  String qrCodeData = qrGenerator.generateQRCodeData(amount);
  print("QR Code Data with CRC: $qrCodeData");
}

class _QRGeneratorPageState extends State {
  TextEditingController _textEditingController = TextEditingController();
  String _qrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter data for QR Code',
                labelText: 'Data',
              ),
              onChanged: (value) {
                setState(() {
                  _qrData = value;
                });
              },
            ),
            SizedBox(height: 20),
            _qrData.isNotEmpty
                ? QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
