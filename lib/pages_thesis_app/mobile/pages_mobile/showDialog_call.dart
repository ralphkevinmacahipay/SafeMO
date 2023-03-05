import 'package:flutter/material.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Condition"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "TERMS AND CONDITIONS",
                    style: styleTitle(),
                  )),
              Text(
                "These phrases and situations (\"Agreement\") set forth the overall phrases and situations of your use of the \"Safaware\" cellular application (\"Mobile Application\" or \"Service\") and any of its associated merchandise and services (collectively \"Services\"). This Agreement is legally binding among you(\"User\", \"you\" or \"your\") and this Mobile Application developer(\"Operator\", \"we\", \"us\" or \"our\"). If you're moving into this settlement o behalf of a commercial enterprise or different prison entity, you constitute which you have the authority, or in case you do now no longer consider the phrases of this settlement, you ought to now no longer receive this settlement and won't get right of entry to and use the Mobile Application and Services. By gaining access to and the usage of the Mobile Application and Services, you renowned which you have read, understood, and comply with be certain with the aid of using the phrases of this Agreement is a agreement among you and Operator, although it is electronic and isn't bodily signed with the aid of using you, and it governs your use of the Mobile Application and Services.",
                textAlign: TextAlign.justify,
                style: _style(),
              ),
              const Spacer(),
              Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "PROHIBITED USES",
                    style: styleTitle(),
                  )),
              Text(
                style: _style(),
                textAlign: TextAlign.justify,
                "In addition to other terms as set forth using in the Agreement, you are prohibited from using the Safaware Application: (a)for any unlawful purpose; (b) to solicit others to perform or particpate in any unlawful acts; (c) to violate any regulations, rules, laws, or local ordinances; (d) to submit false or misleading information; (e) to interfere with or circumvent the security features of the Safaware Application , third party, and services, or the Internet. We reserve the right to terminate your use of the Safaware  Application for violating any of the prohibited uses.",
              ),
              const Spacer(),
              Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "INDEMNIFICATION",
                    style: styleTitle(),
                  )),
              Text(
                style: _style(),
                textAlign: TextAlign.justify,
                "You will indemnify and hold the Operator and its affiliates and officers/authorities harmless from and against any liability, loss, damage, or expense, including reasonable attorneys' fees, arising out of or relating to any claim or claim by any third party. You agree that any dispute or claim brought against any of them as a result of or in connection with your use of Safaware application or your willful misconduct.",
              ),
              const Spacer(),
              Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "CHANGES AND ADDITIONS",
                    style: styleTitle(),
                  )),
              Text(
                style: _style(),
                textAlign: TextAlign.justify,
                "We reserve the right, at our discretion, to change this Agreement or its terms relating to the Safaware Application at any time. If we do, we will revise the updated date at the bottom of this page and post a notice in the Safaware application. We may also notify you in other ways, at our discretion, such as B. Via the contact information you provide. Any updates to this Agreement will be effective immediately upon posting of the revised Agreement unless otherwise stated. Your continued use of your Safaware Application after the effective date of the revised Agreement (or any other action determined at that time) constitutes your acceptance of those changes.",
              ),
              const Spacer(),
              Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "ACCEPTANCE OF THESE TERMS",
                    style: styleTitle(),
                  )),
              Text(
                  style: _style(),
                  textAlign: TextAlign.justify,
                  "You acknowledge that you have read this Agreement and agree to all of its terms. By accessing and using the Safaware Application, you agree to be bound by this Agreement. If you do not agree to the terms of this Agreement, you may not access or use the Safaware Application."),
            ],
          ),
        )),
      ),
    ));
  }

  TextStyle styleTitle() {
    return const TextStyle(
        fontSize: 17, letterSpacing: 3, fontWeight: FontWeight.bold);
  }

  TextStyle _style() {
    return const TextStyle(
      fontSize: 15,
      height: 1.5,
      letterSpacing: BorderSide.strokeAlignOutside,
      wordSpacing: BorderSide.strokeAlignOutside,
    );
  }
}

class Spacer extends StatelessWidget {
  const Spacer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 15,
    );
  }
}
