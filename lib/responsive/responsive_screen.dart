import 'package:flutter/cupertino.dart';
import 'package:login_form_one/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ResponsiveScreen extends StatefulWidget {
  const ResponsiveScreen({super.key, required this.mobileScreen});

  final Widget mobileScreen;

  @override
  State<ResponsiveScreen> createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {

  @override
  void initState(){
    super.initState();
    addData();
  }

  addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // You may want to use the constraints to determine the layout based on screen size
        return widget.mobileScreen;
      },
    );
  }
}
