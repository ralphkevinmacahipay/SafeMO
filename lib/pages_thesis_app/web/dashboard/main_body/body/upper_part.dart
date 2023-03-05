import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BodyUpperPart extends StatelessWidget {
  const BodyUpperPart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("admin").snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 2,
                        style: BorderStyle.solid,
                        color: Colors.black,
                      )),
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 2.0, color: Colors.black)),
                                color: Colors.white),
                            child: Center(
                                child: FittedBox(
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                child: const Text(
                                  "Total Reports in January",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )),
                          ),
                          Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                                child: Text(
                              "${snapshot.data!.size}",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.only(left: 15),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration:
                                    BoxDecoration(border: Border.all(width: 2)),
                                child: ChartForReport(
                                  janNumb: snapshot.data!.size,
                                )),
                          ]),
                    ),
                  )
                ],
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        } else if (snapshot.hasError) {
          return const Text("Error Encountered");
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ChartForReport extends StatelessWidget {
  final int janNumb;
  const ChartForReport({
    super.key,
    required this.janNumb,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(
        text: "Reported Case",
      ),
      primaryXAxis: CategoryAxis(title: AxisTitle(text: "Months")),
      primaryYAxis: NumericAxis(title: AxisTitle(text: "Number of Reports")),
      series: <ChartSeries>[
        ColumnSeries<ReportedCase, String>(
          dataSource: getColumnData(janNumb),
          xValueMapper: (ReportedCase report, _) => report.x,
          yValueMapper: (ReportedCase report, _) => report.y,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
          ),
        )
      ],
    );
  }
}

class ReportedCase {
  String x;
  double y;
  ReportedCase(this.x, this.y);
}

dynamic getColumnData(janNumb) {
  List<ReportedCase> columnData = <ReportedCase>[
    ReportedCase("January", janNumb),
    ReportedCase("February", 0),
    ReportedCase("March", 0),
    ReportedCase("April", 0),
    ReportedCase("May", 0),
    ReportedCase("June", 0),
    ReportedCase("July", 0),
    ReportedCase("August", 0),
    ReportedCase("September", 0),
    ReportedCase("October", 0),
    ReportedCase("November", 0),
    ReportedCase("December", 0),
  ];

  return columnData;
}
