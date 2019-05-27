import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart'; //记得加上这句话
import 'package:flutter_agore/video/VideoCallPage.dart';
import 'package:flutter_agore/audio/AudioCallPage.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //申请权限
  onVideo() async {
    SimplePermissions.requestPermission(Permission.Camera).then((status_first) {
      if (status_first == PermissionStatus.denied) {
        //如果拒绝
        Toast.show("此功能需要授予相机权限", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      } else if (status_first == PermissionStatus.authorized) {
        //如果同意
        SimplePermissions.requestPermission(Permission.RecordAudio)
            .then((status_second) {
          if (status_second == PermissionStatus.denied) {
            //如果拒绝
            Toast.show("此功能需要授予录音权限", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          } else if (status_second == PermissionStatus.authorized) {
            //如果授权同意
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => new VideoCallPage(
                      //视频房间频道号写死，为了方便体验
                      channelName: "122343",
                    ),
              ),
            );
          }
        });
      }
    });
  }

  onAudio() async {
    SimplePermissions.requestPermission(Permission.RecordAudio)
        .then((status_first) {
      if (status_first == PermissionStatus.denied) {
        //如果拒绝
        Toast.show("此功能需要授予录音权限", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      } else if (status_first == PermissionStatus.authorized) {
        //如果授权同意 跳转到语音页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => new AudioCallPage(
                  //频道写死，为了方便体验
                  channelName: "122343",
                ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, //主轴空白区域均分
          children: <Widget>[
            //左按钮
            RaisedButton(
              padding: EdgeInsets.all(0),
              //点击事件
              onPressed: () {
                //去往语音页面
                onAudio();
              },
              child: Container(
                height: 120,
                width: 120,
                //装饰
                decoration: BoxDecoration(

                    //渐变色
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    //圆角12度
                    borderRadius: BorderRadius.circular(12.0)),
                child: Text(
                  "语音通话",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                //文字居中
                alignment: Alignment.center,
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            //右按钮
            RaisedButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                //去往视频页面
                onVideo();
              },
              child: Container(
                height: 120,
                width: 120,
                //装饰--->渐变
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    //圆角12度
                    borderRadius: BorderRadius.circular(12.0)),
                child: Text(
                  "视频通话",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                //文字居中
                alignment: Alignment.center,
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
