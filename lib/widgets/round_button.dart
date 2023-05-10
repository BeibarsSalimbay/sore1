import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  const RoundButton({Key? key,
    required this.title,
    required this.onTap,
    this.loading = false
  }) : super(key: key);

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
  static const Color color3 = Color(0xFF9e9e9e);
  static const Color color4 = Color(0xFFe8eaf2);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color1,
              borderRadius: BorderRadius.circular(50)
        ),
        child: Center(child: loading ? CircularProgressIndicator(strokeWidth: 3,color: Colors.white,) :
        Text(title, style: TextStyle(color: Colors.white),),),
      ),
    );
  }
}
