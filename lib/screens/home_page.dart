import 'package:flutter/material.dart';
import 'package:login_with_aws/providers/auth.dart';
import 'package:login_with_aws/widgets/drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final images = [
    'trek-1.jpg',
    'trek-2.jpg',
    'trek-3.jpg',
    'twelve-apostles.jpg',
    'iam-cli-cheatsheet.jpg',
    'iam-roles-for-ec2.jpg',
    'how-alb-works.jpg',
    'default-vpc.jpg',
    'cognito-pools.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Australia'),
      ),
      drawer: AppDrawer(),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (ctx, i) {
          return SampleItem(images[i]);
        },
        itemCount: images.length,
        padding: const EdgeInsets.all(10),
      ),
    );
  }
}

class SampleItem extends StatelessWidget {
  final String imageName;
  const SampleItem(this.imageName);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {},
          child: Image.asset(
            'assets/images/$imageName',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
