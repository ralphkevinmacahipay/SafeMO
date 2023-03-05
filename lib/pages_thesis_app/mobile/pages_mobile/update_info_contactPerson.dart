import 'package:accounts/no_sql_db/encrypt_decrypt_service.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/utility/addnum_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer' as devstool show log;

class UpdateInfo extends StatefulWidget {
  const UpdateInfo({super.key});
  static String? contactNamePerson;
  static String? contactNumberPerson;
  @override
  State<UpdateInfo> createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {
  final _auth = FirebaseAuth.instance;
  bool? isOTPSUCCES;
  bool? isPhoneVerified;
  bool? isNameIsNotEmpty; //I used this
  bool? isNumberNotEmpty; //I used this
  bool? isOtpNotEmpty; //I used this
  bool? setIconCLear; //I used this
  bool? isNumberValid; //I used this
  bool? setBTNcodeReq; //I used this
  bool? isOTPValid; //I used this
  bool? isTheCodeSent; //I used this
  String? countDown; //I used this
  var letterS = 's'; //I used this
  bool? _isValueCheckBox; //I used this
  final _formKey = GlobalKey<FormState>();
  Verify verify = Verify();
  final TextEditingController myNameControlller = TextEditingController();
  final TextEditingController myNumberController = TextEditingController();
  late final TextEditingController otpController;
  late final TextEditingController countryCodeControlller;

  double boxConstraintsMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double boxConstraintsMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  bool checkIfAllFieldsAreEmpty(
    bool fullname,
    bool number,
    bool otp,
  ) {
    if (fullname && number && otp) {
      return true;
    } else {
      return false;
    }
  }

  bool showSiggUpBTN(
    String fullname,
    String? number,
  ) {
    if (fullname.isNotEmpty && verify.checkingNumber(number)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    isNameIsNotEmpty ??= true; //I used this
    isOtpNotEmpty ??= true; //I used this
    isNumberNotEmpty ??= true; //I used this
    setIconCLear ??= false; //I used this
    isNumberValid ??= true;
    setBTNcodeReq ??= false; //I used this
    isOTPValid ??= true;
    isTheCodeSent ??= false; //I used this
    _isValueCheckBox ??= false; //I used this
    isPhoneVerified ??= false;
    isOTPSUCCES ??= false;

    myNameControlller.text = UpdateInfo.contactNamePerson.toString();
    myNumberController.text = UpdateInfo.contactNumberPerson.toString();

    otpController = TextEditingController();
    countryCodeControlller = TextEditingController();
    countryCodeControlller.text = '+63';

    super.initState();
  }

  @override
  void dispose() {
    // devstool.log("dispose Start");
    myNumberController.dispose();

    otpController.dispose();

    myNameControlller.dispose();
    countryCodeControlller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        validator: (value) {
          setState(() {
            isNameIsNotEmpty = verify.checkIfEmpty(value);
          });
          return null;
        },
        controller: myNameControlller,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.person),
          hintText: 'Name',
          labelText: "Enter Name",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: isNameIsNotEmpty! ? Colors.blue : Colors.red,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
        ),
        onSaved: (value) {
          myNameControlller.text = value!;
        },
        onChanged: (value) {
          setState(() {
            isNameIsNotEmpty = verify.checkIfEmpty(value);
          });
        },
      ),
    );

    final myNumberInput = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        maxLength: 10,
        enableSuggestions: false,
        autocorrect: false,
        controller: myNumberController,
        keyboardType: TextInputType.number,
        validator: (value) {
          setState(() {
            isNumberNotEmpty = verify.checkIfEmpty(value);
            setIconCLear = isNumberNotEmpty;
            isNumberValid = verify.checkingNumber(value);
            setBTNcodeReq = isNumberValid!;
          });
          return null;
        },
        onChanged: (value) {
          setState(() {
            isNumberNotEmpty = verify.checkIfEmpty(value);
            setIconCLear = isNumberNotEmpty;
            isNumberValid = verify.checkingNumber(value);
            setBTNcodeReq = isNumberValid!;
          });
        },
        onSaved: (value) {
          myNumberController.text = value!;
        },
        decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixText: "+63 ",
          prefixIcon: const Icon(Icons.phone),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Visibility(
                visible: setIconCLear!,
                child: const Icon(Icons.cancel_sharp),
              ),
              onPressed: () {
                myNumberController.clear();
                setState(() {
                  setIconCLear = false;

                  isNumberValid = false;
                  setBTNcodeReq = isNumberValid!;
                });
              },
            ),
          ),
          hintText: "9*********",
          labelText: isNumberValid! ? "Number" : "Invalid Number",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: isNumberNotEmpty! && isNumberValid!
                  ? Colors.blue
                  : Colors.red,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
        ),
        textInputAction: TextInputAction.next,
      ),
    );

    final inputOTP = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        maxLength: 6,
        enableSuggestions: true,
        autocorrect: false,
        controller: otpController,
        keyboardType: TextInputType.number,
        validator: (value) {
          isOtpNotEmpty = verify.checkIfEmpty(value);
          setState(() {
            isOtpNotEmpty = verify.checkIfEmpty(value);
          });
          if (value!.length == 6) {
            setState(() {
              isOTPValid = true;
            });
          } else {
            setState(() {
              isOTPValid = false;
            });
          }
          return null;
        },
        onChanged: (value) async {
          final myPhoneNum = myNumberController.text.toString();
          final codeCountry = countryCodeControlller.text.toString();
          String phonVall = "$codeCountry$myPhoneNum";
          setState(() {
            isOtpNotEmpty = verify.checkIfEmpty(value);
          });
          devstool.log("value of isOTPSUCCES berfore function $isOTPSUCCES");
          if (verify.checkingOTPLength(value)) {
            bool getvalue = await verify.verifiedPhoneNumberContact(
                phonVall, value, context);
            setState(() {
              isOTPSUCCES = getvalue;
              devstool.log("value of isOTPSUCCES after function $getvalue");
            });
          } else {
            setState(() {
              isOTPSUCCES = false;
              devstool.log("value of isOTPSUCCES after function $isOTPSUCCES");
            });
          }
          devstool.log("value of isOTPSUCCES after function $isOTPSUCCES");
        },
        decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.password),
          suffixIcon: TextButton(
            onPressed: setBTNcodeReq!
                ? () async {
                    final myPhoneNum = myNumberController.text.toString();
                    final codeCountry = countryCodeControlller.text.toString();
                    String phonVall = "$codeCountry$myPhoneNum";
                    final condeInput = otpController.text.toString();

                    verify.sendVerificationCode(phonVall, condeInput, context);
                    setState(() {
                      isTheCodeSent = true;
                      setBTNcodeReq = false;
                    });

                    for (int i = 120; i >= 0; i--) {
                      if (i == 0) {
                        if (isNumberValid!) {
                          setState(() {
                            setBTNcodeReq = true;
                          });
                        }
                        setState(() {
                          isTheCodeSent = false;
                        });
                      } else {
                        setState(() {
                          countDown = i.toString();
                        });
                        await Future.delayed(const Duration(seconds: 1));
                      }
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(
                isTheCodeSent!
                    ? "Resend in $countDown$letterS"
                    : "Get SMS Code",
                style: TextStyle(
                  color: setBTNcodeReq! ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          hintText: "",
          labelText: isOTPValid! ? "SMS Code" : "6-digit Code",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: isOtpNotEmpty! & isOTPValid!
                  ? const Color.fromARGB(255, 0, 122, 223)
                  : Colors.red,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
        ),
        textInputAction: TextInputAction.next,
      ),
    );

    final submit = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Opacity(
        opacity: 1.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25))),
          onPressed: checkIfAllFieldsAreEmpty(
                    isNameIsNotEmpty!,
                    isNumberNotEmpty!,
                    isOtpNotEmpty!,
                  ) &&
                  isOTPSUCCES!
              ? () async {
                  FirebaseFirestore firebaseFirestore =
                      FirebaseFirestore.instance;
                  User? user = _auth.currentUser;

                  final nameEncryption =
                      EncryptAndDecryptService.encryptionFernet(
                          myNameControlller.text);

                  // encryptedData(data: myNameControlller.text.toString());
                  final numberEncryption =
                      EncryptAndDecryptService.encryptionFernet(
                          myNumberController.text);

                  // encryptedData(data: myNumberController.text.toString());
                  verify.postDetailsToFirestoreAddContactPerson(
                    firebaseFirestore,
                    user,
                    nameEncryption,
                    numberEncryption,
                  );

                  Fluttertoast.showToast(msg: "Saved");
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(splashRoute, (route) => false);
                }
              : null,
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                "Saved",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () async {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(contactpersonRoute, (route) => false);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: boxConstraintsMaxWidth(context),
                      maxWidth: boxConstraintsMaxWidth(context),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(
                              Icons.group_add_rounded,
                              size: 60,
                            ),
                            fullName,
                            myNumberInput,
                            inputOTP,
                            submit,

                            // backButton,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
