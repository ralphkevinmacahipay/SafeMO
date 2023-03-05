import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/congifuration/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../../routes/route_pages.dart';
import '../services_homepage.dart'
    show LocationServiceHome, NavigatorLoadingService;
import 'dart:developer' as devtools show log;

class NavigationDrawerPage extends StatefulWidget {
  const NavigationDrawerPage({super.key});

  @override
  State<NavigationDrawerPage> createState() => _NavigationDrawerPageState();
}

class _NavigationDrawerPageState extends State<NavigationDrawerPage> {
  late NavigatorLoadingService kNavigationService;

  @override
  Widget build(BuildContext context) {
    kNavigationService = NavigatorLoadingService(context: context);

    SizeConfig().init(context);
    return Drawer(
      width: SizeConfig.blockX! * 49.389,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // builderHeader(context),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget builderHeader(context) => Container();

  Widget buildMenuItems(context) {
    return Consumer<LocationServiceHome>(
      builder: (context, services, child) {
        return Container(
          // padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockX! * 3),
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.blockY! * 3,
              ),
              ListTile(
                leading:
                    Icon(Icons.home_outlined, size: SizeConfig.blockX! * 8.944),
                title: Text(
                  "Home",
                  style: kPoppinsBold.copyWith(
                    fontSize: SizeConfig.blockX! * 3.944,
                  ),
                ),
                onTap: kNavigationService.home,
              ),
              ListTile(
                leading: Icon(Icons.report, size: SizeConfig.blockX! * 8.944),
                title: Text(
                  "Report",
                  style: kPoppinsBold.copyWith(
                    fontSize: SizeConfig.blockX! * 3.944,
                  ),
                ),
                onTap: () {
                  devtools.log("User Type before: ${services.getUserType}");
                  QuickAlert.show(
                      cancelBtnTextStyle: kPoppinsBold.copyWith(
                        color: kRed,
                        fontSize: SizeConfig.blockX! * 5,
                      ),
                      showCancelBtn: true,
                      widget: Text(
                        "Do you want to Capture an Inicedent?",
                        style: kPoppinsSemiBold.copyWith(
                            fontSize: SizeConfig.blockX! * 5),
                        textAlign: TextAlign.center,
                      ),
                      title: "",
                      onCancelBtnTap: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      onConfirmBtnTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushNamed(
                          context,
                          incidentReportPageRoute,
                        );
                      },
                      context: context,
                      type: QuickAlertType.warning);

                  devtools.log("Here to choosee User Type");

                  // services.chooseUser(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.app_settings_alt_rounded,
                    size: SizeConfig.blockX! * 8.944),
                title: Text(
                  "About",
                  style: kPoppinsBold.copyWith(
                    fontSize: SizeConfig.blockX! * 3.944,
                  ),
                ),
                onTap: kNavigationService.about,
              ),
              ListTile(
                leading: Icon(Icons.logout_outlined,
                    size: SizeConfig.blockX! * 8.944),
                title: Text(
                  "Logout",
                  style: kPoppinsBold.copyWith(
                    fontSize: SizeConfig.blockX! * 3.944,
                  ),
                ),
                onTap: kNavigationService.logout,
              ),
            ],
          ),
        );
      },
    );
  }
}
