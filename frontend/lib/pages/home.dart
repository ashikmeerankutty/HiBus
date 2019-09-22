import 'package:flutter/material.dart';

import 'pages.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  List<Widget> _pages = <Widget>[Explore(),Scan(),Search(),Offers()];

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: PageContainer(child:_pages.elementAt(_selectedIndex)),
        ),
        bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          title: Text('Explore'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.scanner),
          title: Text('Scan'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.redeem),
          title: Text('Redeem'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help),
          title: Text('Help'),
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      unselectedItemColor: Colors.black,
      fixedColor: Colors.black,
      showUnselectedLabels: true,
    ),);
  }
}

class PageContainer extends StatelessWidget {
  final Widget child;
  PageContainer({Key key, @required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: this.child,
    );
  }
}