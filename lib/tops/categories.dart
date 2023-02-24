import 'package:flutter/material.dart';
import 'package:runomusic/constants/constants.dart';
class Category extends StatefulWidget {
  final List category;
  final void Function(int) getIndex;
  Category(this.category,this.getIndex);

  @override
  State<Category> createState() => _CategoryState();
}
class _CategoryState extends State<Category> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      child: ListView.builder(
          itemCount: widget.category.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context,index){
            return Container(
              margin: EdgeInsets.only(left: 8),
              width: 80,
              decoration: BoxDecoration(
                  color: index==selectedIndex?widgetColor:widgetBackground,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: TextButton(
                onPressed: (){
                  setState(() {
                    widget.getIndex(index);
                    selectedIndex=index;

                  });
                },
                child: Text(widget.category[index],overflow: TextOverflow.ellipsis,style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                )),
              ),
            );
          }
      ),
    );
  }
}
