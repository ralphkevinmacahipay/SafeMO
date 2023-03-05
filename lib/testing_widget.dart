import 'package:flutter/material.dart';

class TestWidgetHere extends StatelessWidget {
  const TestWidgetHere({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 200,
        width: 100,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "https://scontent.fmnl13-1.fna.fbcdn.net/v/t39.30808-6/323887590_2446063242209663_3545525076231171325_n.jpg?stp=cp6_dst-jpg_p526x296&_nc_cat=103&ccb=1-7&_nc_sid=8bfeb9&_nc_eui2=AeEVyN18iEEVucvBWAzi9jq-KaaVUaerqPkpppVRp6uo-ctgE9wcr1AG0Mx_TL8z5WOH3ho4ElvzBxoCxcx7Et06&_nc_ohc=LNny9HvpskMAX_iyCRB&_nc_ht=scontent.fmnl13-1.fna&oh=00_AfAxy5XZNwaJRMad7SdP796hFE9-_PuLii-J-fnC9CnGeg&oe=63D3631D"))),
      ),
    );
  }
}
