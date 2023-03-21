import 'package:accounts/pages_thesis_app/web/user_location/user_location.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:flutter/material.dart';

import 'package:accounts/services/auth/auth_service.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white70),
              child: Image.asset(logo),
            ),
            DrawerListTile(
              image: Icons.dashboard_rounded,
              press: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, webHomePage, (route) => false);
              },
              title: "Dashboard",
            ),
            DrawerListTile(
              image: Icons.map_rounded,
              press: () {
                UserLocation.isThisReport = false;
                Navigator.pushNamedAndRemoveUntil(
                    context, userLocationWebRoute, (route) => false);
              },
              title: "Map",
            ),
            DrawerListTile(
              image: Icons.history_edu_rounded,
              press: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    historyReportPageRoute, (route) => false);
              },
              title: "Report History",
            ),
            DrawerListTile(
              image: Icons.logout_rounded,
              press: () async {
                await AuthService.firebase().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    adminLoginPageRoute, (route) => false);
              },
              title: "Logout",
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.image,
    required this.press,
  });
  final String title;
  final IconData image;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(
        image,
        color: Colors.black,
      ),
      title: Text(title),
    );
  }
}
