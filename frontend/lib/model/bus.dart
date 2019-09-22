class Bus {

  final double distance;
  final String regId;
  final String busId;
  final String type;
  final String lastSeenAt;
  final Map<dynamic,dynamic> lastKnown;
  final Map<dynamic,dynamic> from;
  final Map<dynamic,dynamic> to;
  final Map<dynamic,dynamic> route;

  Bus({this.distance, this.regId, this.busId, this.type,this.lastSeenAt,this.lastKnown,this.from,this.to,this.route });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      distance: json['distance'],
      regId: json['regId'],
      busId: json['busId'],
      type: json['type'],
      lastSeenAt: json['lastSeenAt'],
      lastKnown: json['lastKnown'],
      from: json['from'],
      to: json['to'],
      route: json['route']
    );
  }
}