import 'dart:io';
import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/congifuration/style.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/commuter_page/services_homepage.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/user_service_type/user_type_enum.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../sound_image_code/sound_images_code.dart';
import 'dart:developer' as devtools show log;

import '../commuter_page/services_report_commuter.dart';

class IncidentReport extends StatefulWidget {
  const IncidentReport({
    super.key,
  });

  @override
  State<IncidentReport> createState() => _IncidentReportState();
}

class _IncidentReportState extends State<IncidentReport> {
  TextEditingController? dscController;
  TextEditingController? headCountController;
  bool? isCapture;
  String imgURL = "unable to capture",
      strTitle = "",
      dscStr = "",
      headCount = '';

  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isCapture ??= false;
    dscController ??= TextEditingController();
    headCountController ??= TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dscController!.dispose();
    headCountController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // drawer: const NavigationDrawer(),
      appBar: AppBar(
          title: Text(
        "Report Incident",
        style: kPoppinsBold.copyWith(
          fontSize: SizeConfig.blockX! * 5.944,
        ),
      )),
      backgroundColor: kGreyBackGround,
      body: Consumer2<LocationServiceHome, ReportCommuterServices>(
        builder: (context, servicesLoc, servicesReport, child) {
          // services.setTypeOfUser(UserTypeEnum.report);,
          return ListView(
            children: [
              Container(
                decoration: const BoxDecoration(color: kWhite),
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockX! * 10,
                    vertical: SizeConfig.blockY! * 2.75),
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.blockX! * 10),
                child: DropDownButton(
                  items: servicesReport.getListItems,
                  selectedItem: servicesReport.getSelectedItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      servicesReport.setSelectedItem(newValue!);
                    });
                  },
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: kWhite),
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockX! * 10,
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.blockX! * 10),
                child: TextFormField(
                  controller: headCountController,
                  onSaved: (value) {
                    headCountController!.text = value!;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Number of Person Involved",
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),
              Center(
                child: Text(
                  "Short Description",
                  style: kPoppinsSemiBold.copyWith(
                      fontSize: SizeConfig.blockX! * 6.556),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockY! * 2.875,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockX! * 10.167),
                decoration: const BoxDecoration(color: kWhite),
                height: SizeConfig.blockY! * 30.75,
                width: SizeConfig.blockX! * 50.945,
                child: TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    controller: dscController,
                    onSaved: (value) {
                      dscController!.text = value!;
                    },
                    style: kPoppinsMediumBold.copyWith(
                        letterSpacing: .5,
                        fontSize: SizeConfig.blockX! * 4.556),
                    keyboardType: TextInputType.multiline,
                    maxLines: 12,

                    // maxLines: ,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: SizeConfig.blockX! * 4.167,
                            top: SizeConfig.blockY! * 1),
                        hintText: "e.g. Sunog sa burgos street",
                        hintStyle: kPoppinsMediumBold.copyWith(
                            color: kLighterGrey,
                            fontSize: SizeConfig.blockX! * 4.556),
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide.none))),
              ),
              SizedBox(
                height: SizeConfig.blockY! * 2.375,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onTapCapture(servicesLoc);
                        },
                        child: AnimatedCrossFade(
                          firstChild: Image.asset(
                            cameraIcon,
                            width: SizeConfig.blockX! * 15,
                            height: SizeConfig.blockX! * 15.556,
                          ),
                          secondChild: Image.asset(
                            captureIcon,
                            width: SizeConfig.blockX! * 15,
                            height: SizeConfig.blockX! * 15.556,
                          ),
                          crossFadeState: isCapture!
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(
                            seconds: 2,
                          ),
                        ),
                      ),
                      Text(
                        "(Optional)",
                        style: kPoppinsSemiBold.copyWith(
                          fontSize: SizeConfig.blockX! * 4,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: servicesLoc.getLatLngStream,
                        child: AnimatedCrossFade(
                          firstChild: Image.asset(
                            setDesIcon,
                            width: SizeConfig.blockX! * 15,
                            height: SizeConfig.blockX! * 15.556,
                          ),
                          secondChild: Image.asset(
                            findLoc,
                            width: SizeConfig.blockX! * 15,
                            height: SizeConfig.blockX! * 15.556,
                          ),
                          crossFadeState: servicesLoc.getIsPinLoc
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(
                            seconds: 2,
                          ),
                        ),
                      ),
                      Text(
                        "Pin Location",
                        style: kPoppinsSemiBold.copyWith(
                          fontSize: SizeConfig.blockX! * 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockY! * 2.75,
              ),
              Center(
                child: GestureDetector(
                  onTap: () => _onTapReport(servicesReport),
                  child: Container(
                    decoration: BoxDecoration(
                        color: kRed,
                        borderRadius: BorderRadius.circular(kBorderRadius)),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockX! * 26.339,
                      vertical: SizeConfig.blockY! * 1.5,
                    ),
                    child: Text(
                      "Report",
                      style: kPoppinsBold.copyWith(
                        fontSize: SizeConfig.blockX! * 5.556,
                        color: kWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  onTapCapture(LocationServiceHome servicesLoc) async {
    devtools.log("Report Incident");

    // dito yung pag open ng camera
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

    if (file == null) return servicesLoc.setTypeOfUser(UserTypeEnum.report);
    // devtools.log("UserType is : ${UserTypeEnum.report}");;
    String uniquefileName = DateTime.now().microsecondsSinceEpoch.toString();

    // Get the instance of firebase_storage
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImage = referenceRoot.child("image");

    // kunin yung reference ng image then e assign sa unique filename
    Reference referenceImageImageToUpload =
        referenceDirImage.child(uniquefileName);
    QuickAlert.show(
      text: "",
      title: "Saving Photo",
      context: context,
      type: QuickAlertType.loading,
      autoCloseDuration: const Duration(seconds: 7),
    );
    try {
      // code  para ma upload sa firebase storage
      await referenceImageImageToUpload.putFile(File(file.path));

      // success: get the url
      imgURL = await referenceImageImageToUpload.getDownloadURL();
    } catch (error) {
      devtools.log(error.toString());
    }
    setState(() {
      isCapture = true;
    });
  }

  _onTapReport(ReportCommuterServices servicesReport) async {
    if (dscController!.text.isEmpty) {
      QuickAlert.show(
        title: "",
        widget: Text(
          "Empty Short\nDescription or Number of Person",
          style: kPoppinsBold.copyWith(
            fontSize: SizeConfig.blockX! * 5.556,
          ),
          textAlign: TextAlign.center,
        ),
        animType: QuickAlertAnimType.slideInUp,
        context: context,
        type: QuickAlertType.warning,
      );
    } else {
      final show = QuickAlert.show(
        text: "",
        title: "Sending Report",
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        type: QuickAlertType.loading,
      );
      dscStr = dscController!.text;
      headCount = headCountController!.text;

      servicesReport.setDescription(dscStr);
      servicesReport.setScene(imgURL);
      servicesReport.setHeadCount(headCount);
      servicesReport.insertCaseReport();
      setState(() {
        dscController!.clear();
        headCountController!.clear();
        servicesReport.setSelectedItem("Incident");
        imgURL = "";
        dscStr = "";
        FocusScope.of(context).unfocus();
        isCapture = false;
      });
      show.whenComplete(
        () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: kBlueSnackBar,
            content: Text(
              "Incident Reported",
              textAlign: TextAlign.center,
              style: kPoppinsSemiBold.copyWith(
                  fontSize: SizeConfig.blockX! * 4.611),
            ),
          ),
        ),
      );
    }
  }
}
