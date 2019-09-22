class Coupon {

  final bool status;
  final String promocode;
  final Map<String,dynamic> brand;
  final String busId;


  Coupon({this.status, this.promocode, this.brand, this.busId});

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      status: json['status'],
      promocode: json['promoCode'],
      brand: json['brand'],
      busId: json['busId'],
    );
  }
}