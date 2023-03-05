import 'package:accounts/sms_utility/sms_api.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer' as devstool show log;

import 'package:twilio_phone_verify/twilio_phone_verify.dart';

class Verify {
  final TwilioPhoneVerify _twilioPhoneVerify = TwilioPhoneVerify(
      accountSid: accointSID, // replace with Account SID
      authToken: accounttoken, // replace with Auth Token
      serviceSid: serviceSID // replace with Service SID
      );
  bool checkIfEmpty(data) {
    if (data.isEmpty) {
      devstool.log("Code Is here in inside if make it false");
      return false;
    } else {
      devstool.log("Code Is here in inside else make it true");
      return true;
    }
  }

  bool checkingNumber(value) {
    if (value.length != 10) {
      return false;
    } else {
      return true;
    }
  }

  bool checkingOTPLength(value) {
    if (value.length != 6) {
      return false;
    } else {
      return true;
    }
  }

  timerWait() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  bool checkingOTP(String? phoneVal, value, context) {
    if (value.length == 6) {
      timerWait();
      verifiedPhoneNumber(phoneVal!, value.toString(), context);
      return true;
    } else {
      return false;
    }
  }

  void verifiedPhoneNumber(String phone, String codeInput, context) async {
    var twilioResponse =
        await _twilioPhoneVerify.verifySmsCode(phone: phone, code: codeInput);

    if (twilioResponse.successful!) {
      if (twilioResponse.verification!.status == VerificationStatus.approved) {
        Fluttertoast.showToast(msg: "Phone Verified");
        //print('Phone number is approved');
      } else {
        //print('Invalid code');

        showErrorDialog(context, "The Code $codeInput is INVALID");
      }
    } else {
      //print(twilioResponse.errorMessage);
      Fluttertoast.showToast(msg: "Failed To Verified");
    }
  }

  sendVerificationCode(String phoneVal, String codeInput, context) async {
    var twilioResponse = await _twilioPhoneVerify.sendSmsCode(phoneVal);

    if (twilioResponse.successful!) {
      return;
    } else {
      devstool.log(twilioResponse.errorMessage.toString());
      showErrorDialog(context, 'Code Cannot Send');
    }
  }

  verifiedPhoneNumberContact<bool>(
      String phone, String codeInput, context) async {
    var twilioResponse =
        await _twilioPhoneVerify.verifySmsCode(phone: phone, code: codeInput);

    if (twilioResponse.successful!) {
      if (twilioResponse.verification!.status == VerificationStatus.approved) {
        Fluttertoast.showToast(msg: "Phone Verified");
        return true;
        //print('Phone number is approved');
      } else {
        //print('Invalid code');

        showErrorDialog(context, "The Code $codeInput is INVALID");
        return false;
      }
    } else {
      //print(twilioResponse.errorMessage);
      Fluttertoast.showToast(msg: "Failed To Verified");
      return false;
    }
  }

  postDetailsToFirestoreAddContactPerson(
    firebaseFirestore,
    user,
    nameEncryption,
    numberEncryption,
  ) async {
    await firebaseFirestore.collection("users").doc(user!.uid).update({
      'contactPerson': {
        "Name": nameEncryption.base64,
        "contactNumber": numberEncryption.base64,
      }
    }).then((value) => Fluttertoast.showToast(msg: "Saved")
        .catchError((error) => Fluttertoast.showToast(msg: "Cannot Save")));
  }
}
