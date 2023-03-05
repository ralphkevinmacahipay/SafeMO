import 'package:accounts/pages_thesis_app/mobile/chooseUser/choseUser.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/incidentReport/incidentReport.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/commuter_page/services_homepage.dart';
import 'package:accounts/pages_thesis_app/mobile/three_dot_pages/contactPerson.dart';
import 'package:accounts/pages_thesis_app/mobile/three_dot_pages/profile.dart';
import 'package:accounts/pages_thesis_app/web/admin_login.dart';
import 'package:accounts/pages_thesis_app/web/fake_report/fake_report.dart';
import 'package:accounts/pages_thesis_app/web/user_location/services_report_history.dart';
import 'package:accounts/pages_thesis_app/web/user_location/user_location.dart';
import 'package:accounts/pages_thesis_app/web/web_home.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages_thesis_app/mobile/alarm_service/alarm_service.dart';
import 'pages_thesis_app/mobile/chooseUser/commuter_page/commuter_page.dart';
import 'pages_thesis_app/mobile/chooseUser/commuter_page/services_report_commuter.dart';
import 'pages_thesis_app/mobile/pages_mobile/added_contact_person.dart';
import 'pages_thesis_app/mobile/pages_mobile/email_verify.dart';
import 'pages_thesis_app/mobile/pages_mobile/forgot_password.dart';
import 'pages_thesis_app/mobile/pages_mobile/home_page.dart';
import 'pages_thesis_app/mobile/pages_mobile/login_page.dart';
import 'pages_thesis_app/mobile/pages_mobile/register_page.dart';
import 'pages_thesis_app/mobile/pages_mobile/showDialog_call.dart';
import 'pages_thesis_app/mobile/pages_mobile/splash_screen.dart';
import 'pages_thesis_app/mobile/pages_mobile/update_info_contactPerson.dart';
import 'pages_thesis_app/mobile/pages_mobile/update_info_user.dart';
import 'pages_thesis_app/mobile/three_dot_pages/about.dart';
import 'pages_thesis_app/web/history_report/history_report.dart';
import 'pages_thesis_app/web/user_location/services_record.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService.firebase().initialize();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => ReportCommuterServices(),
      ),
      ChangeNotifierProvider(
        create: (context) => LocationServiceHome(context),
      ),
      ChangeNotifierProvider(
        create: (context) => RecordServices(),
      ),
      ChangeNotifierProvider(
        create: (context) => HistoryServicesReport(context),
      ),
    ], child: const MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final currentWith = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //this is just modified for no reason
      home: currentWith <= 400
          ? const InitializerPageMobile()
          : const InitializePageWeb(),
      routes: {
        registerPageRoute: (context) => const RegisterPage(),
        homePageRoute: (context) => const HomePage(),
        verifyEmailRoute: (context) => const VerifyEmailPage(),
        loginPageRoute: (context) => const LoginPage(),
        splashRoute: (context) => const SplashView(),
        addCOntactPersonRoute: (context) => const ContactPersonAdded(),
        profilePageRoute: (context) => const ProfilePage(),
        webHomePage: (context) => const WebHomePage(),
        userLocationWebRoute: (context) => const UserLocation(),
        adminLoginPageRoute: (context) => const AdminLoginPage(),
        contactpersonRoute: (context) => const ContactPersonProfile(),
        contactPageRoute: (context) => const AboutUs(),
        forgotpasswordPageRoute: (context) => const ForgotPassword(),
        updateInfoPageRoute: (context) => const UpdateInfo(),
        updateInfoUserPageRoute: (context) => const UpdateInfoUser(),
        historyReportPageRoute: (context) => const HistoryReport(),
        termsOfUsePageRoute: (context) => const TermsOfUse(),
        chooseUserPageRoute: (context) => const ChooseUser(),
        incidentReportPageRoute: (context) => const IncidentReport(),
        updatedHomePageRoute: (context) => const CommuterPage(),
        alarmScreenRoute: (context) => CountdownPage(),
        fakeReportPageRoute: (context) => const FakeReport(),
      },
    );
  }
}

class InitializerPageMobile extends StatefulWidget {
  const InitializerPageMobile({Key? key}) : super(key: key);

  @override
  State<InitializerPageMobile> createState() => _InitializerPageMobileState();
}

class _InitializerPageMobileState extends State<InitializerPageMobile> {
  @override
  Widget build(BuildContext context) {
    // Para ma store yung user (no need na mag login pag verified na ang email)

    return FutureBuilder(
      // initializeApp (isang beses lang dapat gawin hindi  per widget)
      future: AuthService.firebase().initialize(),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return const SplashView();

          default:
            return DefaultSplashView().defaultSplash();
        }
      }),
    );
  }
}

class InitializePageWeb extends StatefulWidget {
  const InitializePageWeb({super.key});

  @override
  State<InitializePageWeb> createState() => _InitializePageWebState();
}

class _InitializePageWebState extends State<InitializePageWeb> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // AdminLoginPage WebHomePage TestWidgetHere
            return const AdminLoginPage();
          default:
            return DefaultSplashView().defaultSplash();
        }
      }),
    );
  }
}
