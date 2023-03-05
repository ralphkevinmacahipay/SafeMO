import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});
  double boxConstraintsMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double boxConstraintsMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
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
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 40, top: 40),
                child: Image.asset(
                  logo,
                  height: 100,
                  width: 100,
                ),
              ),
              Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 40),
                  child: const Text(
                    "About Us",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  )),
              Padding(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "The \"SafAware\" is the online platform for commuters where they can send report directly to 911 if they're in danger, and 911 will able to locate the victim.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "\"Using this application, we provide safty awareness for commuters and fast-paced rescue operation for 911\"",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 17,
                          ),
                        ),
                        TextButton(
                            // TODO Terms of use
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(termsOfUsePageRoute);
                            },
                            child: Container(
                              margin: const EdgeInsetsDirectional.only(top: 20),
                              child: const Text(
                                "Terms & Conditions",
                                style: TextStyle(fontSize: 15),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
