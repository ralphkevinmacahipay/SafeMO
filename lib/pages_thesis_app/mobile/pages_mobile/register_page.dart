import 'dart:async';
import 'package:accounts/no_sql_db/encrypt_decrypt_service.dart';
import 'package:accounts/no_sql_db/nosql_db.dart';
import 'package:accounts/utility/addnum_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_exception.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String codeReceived = "";
  bool isBoxChecked = true;
  bool areAllInputfilled = true;
  bool isOTPVerified = false;

  // Empty Checking
  bool? isNameIsNotEmpty; //I used this
  bool? isMyEmailNotEmpty; //I used this
  bool? isOtpNotEmpty; //I used this
  bool? isNumberNotEmpty; //I used this
  bool? isPassNotEmpty; //I used this
  bool? isRePassNotEmpty; //I used this
  bool? showKey;

// Valid Input Checking
  bool? isMyEmailValid; //I used this
  bool? isNumberValid; //I used this
  bool? isOTPValid; //I used this
  bool? isPassValid; //I used this

  //Other
  bool? _isValueCheckBox; //I used this
  bool? setIconCLear; //I used this
  bool? setBTNcodeReq; //I used this
  bool? isTheCodeSent; //I used this
  String? countDown; //I used this
  Timer? timer; //I used this
  var letterS = 's'; //I used this
  bool? isPassMatch; //I used this
  bool? isNumberVerified;

  Verify verify = Verify();

  bool passwordInVisible = true;
  bool repasswordInVisible = true;

  final _auth = FirebaseAuth.instance;
  bool value = false;
  String? dropDownValue = "Male";
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController myNameController;
  late final TextEditingController myNumberControlller;
  late final TextEditingController myEmailController;
  late final TextEditingController otpController;
  late final TextEditingController passwordController;
  late final TextEditingController reInputPasswordController;

  late final TextEditingController countryCodeControlller;
  // TwilioPhoneVerify _twilioPhoneVerify;

  @override
  void initState() {
    myNameController = TextEditingController();
    myNumberControlller = TextEditingController();
    myEmailController = TextEditingController();
    otpController = TextEditingController();
    passwordController = TextEditingController();
    reInputPasswordController = TextEditingController();

    countryCodeControlller = TextEditingController();
    countryCodeControlller.text = '+63';

    //initial value Empty
    isNameIsNotEmpty ??= true; //I used this
    isMyEmailNotEmpty ??= true; //I used this
    isNumberNotEmpty ??= true; //I used this
    isOtpNotEmpty ??= true; //I used this
    isPassNotEmpty ??= true; //I used this
    isRePassNotEmpty ??= true; //I used this
    _isValueCheckBox ??= false; //I used this
    setIconCLear ??= false; //I used this
    setBTNcodeReq ??= false; //I used this
    isTheCodeSent ??= false; //I used this
    isOTPValid ??= true;
    showKey ??= false;
    isNumberVerified ??= false;

    // initial value Valid
    isMyEmailValid ??= true;
    isNumberValid ??= true;
    isPassValid ??= true;
    isPassMatch ??= true;

    super.initState();
  }

  @override
  void dispose() {
    // devstool.log("dispose Start");
    myNumberControlller.dispose();
    myEmailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    reInputPasswordController.dispose();
    myNameController.dispose();
    countryCodeControlller.dispose();

    super.dispose();
  }

  void onButtonTappedVerify() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.of(context).pushNamed(verifyEmailRoute);
  }

  void onButtonTappedHomePage() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(homePageRoute, (route) => false);
  }

  bool validateRegEmail(data) {
    RegExp regex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (regex.hasMatch(data!)) {
      return true;
    } else {
      return false;
    }
  }

  bool validateRegPassword(data) {
    RegExp regex = RegExp(r'^.{6,}$');
    if (regex.hasMatch(data!)) {
      return true;
    } else {
      return false;
    }
  }

  bool showSiggUpBTN(String fullname, String email, String? number,
      String? pass, String? repass) {
    if (fullname.isNotEmpty &&
            validateRegEmail(email) &&
            verify.checkingNumber(number) &&
            validateRegPassword(pass) &&
            pass == repass
        // &&
        //     number != null &&
        //     otp != null &&
        //     pass != null &&
        //     repass != null
        ) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAllFieldsAreEmpty(bool fullname, bool email, bool number,
      bool otp, bool pass, bool repass) {
    if (fullname && email && number && otp && pass && repass) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------->  SignUp Display <---------------------------
    const signUpDisplay = Text(
      'SIGN UP',
      style: TextStyle(
        color: Colors.black,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );

    // --------------------------->  Fullname User <----------------------------
    final fullName = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        validator: (value) {
          setState(() {
            isNameIsNotEmpty = verify.checkIfEmpty(value);
          });
          return null;
        },
        controller: myNameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.person),
          hintText: 'Name',
          labelText: "e.g. Juan Dela Cruz",
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
          myNameController.text = value!;
        },
        onChanged: (value) {
          setState(() {
            isNameIsNotEmpty = verify.checkIfEmpty(value);
          });
        },
      ),
    );
    // --------------------------->  Email User <----------------------------
    final inputEmail = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: myEmailController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.email),
          hintText: 'Email',
          labelText: isMyEmailValid! ? "Enter Email" : "Invalid Email",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: isMyEmailNotEmpty! && isMyEmailValid!
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
        validator: (value) {
          setState(() {
            isMyEmailNotEmpty = verify.checkIfEmpty(value);
            isMyEmailValid = validateRegEmail(value);
          });
          return null;
        },
        onSaved: (value) {
          myEmailController.text = value!;
        },
        onChanged: (value) {
          setState(() {
            isMyEmailNotEmpty = verify.checkIfEmpty(value);
            isMyEmailValid = validateRegEmail(value);
          });
        },
      ),
    );

    // --------------------------->  My Number User <----------------------------
    final myNumberInput = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        maxLength: 10,
        enableSuggestions: false,
        autocorrect: false,
        controller: myNumberControlller,
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
          myNumberControlller.text = value!;
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
                myNumberControlller.clear();
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

    // ---------------------------> OTP input <------------------------------
    final inputOTP = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        maxLength: 6,
        enableSuggestions: true,
        autocorrect: false,
        controller: otpController,
        keyboardType: TextInputType.number,
        validator: (value) {
          final myPhoneNum = myNumberControlller.text.toString();
          final codeCountry = countryCodeControlller.text.toString();
          String phonVall = "$codeCountry$myPhoneNum";
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
        onChanged: (value) {
          final myPhoneNum = myNumberControlller.text.toString();
          final codeCountry = countryCodeControlller.text.toString();
          String phonVall = "$codeCountry$myPhoneNum";
          setState(() {
            isOtpNotEmpty = verify.checkIfEmpty(value);
            isOTPValid = verify.checkingOTP(phonVall, value, context);
          });
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
            // TODO send ng OTP
            onPressed: setBTNcodeReq!
                ? () async {
                    final myPhoneNum = myNumberControlller.text.toString();
                    final codeCountry = countryCodeControlller.text.toString();
                    String phonVall = "$codeCountry$myPhoneNum";
                    final condeInput = otpController.text.toString();
                    // TODO change this
                    verify.sendVerificationCode(phonVall, condeInput, context);
                    setState(() {
                      isTheCodeSent = true;
                      setBTNcodeReq = false;
                    });

                    //TODO NOT SEND SMS CODE
                    //   verifyPhone(phonVall, condeInput);

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

    // ---------------------------> password input <----------------------------
    final inputPassword = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        obscureText: passwordInVisible,
        enableSuggestions: false,
        autocorrect: false,
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          setState(() {
            isPassNotEmpty = verify.checkIfEmpty(value);
            isPassValid = validateRegPassword(value);
          });
          return null;
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        onChanged: (value) {
          setState(() {
            isPassNotEmpty = verify.checkIfEmpty(value);
            isPassValid = validateRegPassword(value);
          });
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                passwordInVisible = !passwordInVisible;
              });
            },
            icon: Icon(
                passwordInVisible ? Icons.visibility_off : Icons.visibility),
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.vpn_key_sharp),
          hintText: "Enter your password",
          labelText: isPassValid! ? "Password" : "Min. 6 characters",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: isPassValid! && isPassNotEmpty! ? Colors.blue : Colors.red,
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

    // ---------------------------> re-input password input <-------------------
    final reInputPassword = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        obscureText: repasswordInVisible,
        enableSuggestions: false,
        autocorrect: false,
        controller: reInputPasswordController,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          isRePassNotEmpty = verify.checkIfEmpty(value);
          if (isRePassNotEmpty!) {
            if (reInputPasswordController.text == passwordController.text) {
              setState(() {
                isPassMatch = true;
              });
              // devstool.log("Password do not match");
            } else {
              setState(() {
                isPassMatch = false;
              });
            }
          }
          return null;
        },
        onChanged: (value) {
          isRePassNotEmpty = verify.checkIfEmpty(value);
          if (isRePassNotEmpty!) {
            if (reInputPasswordController.text == passwordController.text) {
              setState(() {
                isPassMatch = true;
              });
              // devstool.log("Password do not match");
            } else {
              setState(() {
                isPassMatch = false;
              });
            }
          }
        },
        onSaved: (value) {
          reInputPasswordController.text = value!;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                repasswordInVisible = !repasswordInVisible;
              });
            },
            icon: Icon(
                repasswordInVisible ? Icons.visibility_off : Icons.visibility),
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.vpn_key_sharp),
          hintText: "Confirm Password",
          labelText:
              isPassMatch! ? "Confirm Password" : "Password do not match",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color:
                  isPassMatch! && isRePassNotEmpty! ? Colors.blue : Colors.red,
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
        textInputAction: TextInputAction.done,
      ),
    );

    // ---------------------------> Gender <------------------------------------
    late final inputGender = DropdownButton(
      underline: Container(color: Colors.transparent),
      value: dropDownValue,
      onChanged: (String? newValue) {
        setState(() {
          dropDownValue = newValue;
        });
      },
      items: <String>['Male', 'Female', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

// ---------------------------> Dispay Gender <---------------------------------
    final displayGenderRow = Padding(
      padding: const EdgeInsets.only(right: 50),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(
              right: 10,
              left: 30,
            ),
            child: Text(
              "Gender:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          inputGender,
        ],
      ),
    );

// ------------------------------ Terms and Conditions -------------------------
//TODO: TERMS AND CONDIDTOIN
    final btnTermsAndCondition = TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed(termsOfUsePageRoute);
      },
      child: const Text('Terms and Conditions'),
    );

    final displayTermsCondition = Row(
      children: [
        Expanded(
          child: SizedBox(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Column(
                children: [
                  Row(
                    children: [
                      const Text('I agree to '),
                      btnTermsAndCondition,
                    ],
                  ),
                ],
              ),
              value: _isValueCheckBox,
              onChanged: (value) {
                setState(() {
                  _isValueCheckBox = value!;
                });
              },
            ),
          ),
        ),
      ],
    );

// ---------------------------> Sign Up Button <--------------------------------

    final registerButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Opacity(
        opacity: 1.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25))),
          onPressed: _isValueCheckBox! &&
                  checkIfAllFieldsAreEmpty(
                      isNameIsNotEmpty!,
                      isMyEmailNotEmpty!,
                      isNumberNotEmpty!,
                      isOtpNotEmpty!,
                      isPassNotEmpty!,
                      isRePassNotEmpty!)
              ? () async {
                  final codeInput = otpController.text.toString();
                  final email = myEmailController.text.toString();
                  final password = passwordController.text.toString();

                  final myPhoneNum = myNumberControlller.text.toString();
                  final codeCountry = countryCodeControlller.text.toString();
                  String phonVall = "$codeCountry$myPhoneNum";

                  if (_formKey.currentState!.validate()) {
                    try {
                      if (showSiggUpBTN(
                        myNameController.text.toString(),
                        myEmailController.text.toString(),
                        myNumberControlller.text.toString(),
                        passwordController.text.toString(),
                        reInputPasswordController.text.toString(),
                      )) {
                        singUp(email, password);
                      } else {
                        showErrorDialog(context, 'Please All Fields');
                      }
                    } on UserAlreadyExistsAuthException {
                      showErrorDialog(context, 'Email already exists');
                    } on GenericAuthException {
                      showErrorDialog(context, "Register failed");
                    }
                  }
                }
              : null,
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                "Sign Up",
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

// ---------------------------> Scaffold <---------------------------
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
                .pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Form(
                key: _formKey,
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      signUpDisplay,
                      const SizedBox(height: 10),
                      fullName,
                      const SizedBox(height: 10),
                      inputEmail,
                      const SizedBox(height: 10),
                      myNumberInput,
                      const SizedBox(height: 10),
                      inputOTP,
                      const SizedBox(height: 10),
                      inputPassword,
                      const SizedBox(height: 10),
                      reInputPassword,
                      const SizedBox(height: 10),
                      displayGenderRow,
                      displayTermsCondition,
                      const SizedBox(height: 10),
                      registerButton

                      // backButton
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        /* add child content here */
      ),
    );
  }

  void singUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore()})
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

  postDetailsToFirestore() async {
    // calling our firestore
    //calling our user model
    // sending this value

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();
    // TODO FIX THIS yung encrption mali pree

    final nameEncryption =
        EncryptAndDecryptService.encryptionFernet(myNameController.text);
    final emailEncryption = encryptedData(data: user!.email.toString());
    final myNumberEncryption =
        EncryptAndDecryptService.encryptionFernet(myNumberControlller.text);
    /*   final dataDecryption = decryptedData(data: dataEncryption);
   devstool.log(dataEncryption.base64);
     devstool.log(dataDecryption);
*/
    userModel.email = emailEncryption.base64;
    userModel.uid = user.uid;
    userModel.fullname = nameEncryption.base64;
    userModel.gender = dropDownValue;
    userModel.myNumber = myNumberEncryption.base64;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    Fluttertoast.showToast(msg: "Account created Succesfully");
    Navigator.pushNamedAndRemoveUntil(context, splashRoute, (route) => false);
  }
}
