import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_agore/model/VideoUserSession.dart';

class videoCallPage extends StatefulWidget{

  //频道号 上个页面传递
  String channelName;

  videoCallPage({Key key,this.channelName}) : super(key:key);


  @override
  State<StatefulWidget> createState(){
    return new videoCallState();
  }
}


class videoCallState extends State<videoCallPage> {

  //声网sdk的appId
  String agore_appId = "6d936474d3ad4c1584a612dfebd2c529";

  //用户seesion对象
  List _userSessions = List<VideoUserSession>();


  @override
  void initState(){
    super.initState();
    //初始化SDK
    initAgoreSdk();
    //事件监听回调
    setAgoreEventListener();


  }

  void initAgoreSdk(){
    //初始化引擎
    AgoraRtcEngine.create(agore_appId);
    //设置视频为可用 启用视频模块
    AgoraRtcEngine.enableVideo();



  }

  //设置事件监听
  void setAgoreEventListener(){
    //成功加入房间
    AgoraRtcEngine.onJoinChannelSuccess = (String channel,int uid,int elapsed){
      print("成功加入房间,频道号:$channel");
    };

    //监听是否有新用户加入
    AgoraRtcEngine.onUserJoined = (int uid,int elapsed){
      print("新用户所加入的id为:$uid");
    };

    //监听用户是否离开这个房间
    AgoraRtcEngine.onUserOffline = (int uid,int reason){
      print("用户离开的id为:$uid");

    };


  }


  //创建渲染视图
  void _createRendererView(int uid,Function(int viewId) successCreate){
    //该方法创建视频渲染视图，返回 SurfaceView 的类型。View 的操作和布局由 App 管理，
    //Agora SDK 在 App 提供的 View 上进行渲染。显示视频视图必须调用该方法，而不是直接调用 SurfaceView。
    Widget view = AgoraRtcEngine.createNativeView(uid, (viewId){
        setState(() {

        });
    });

  }


  //根据uid来获取session session为了视频布局需要
  VideoUserSession _getVideoUidSession(int uid){
    //满足条件的第一个元素
    return _userSessions.firstWhere(agore_appId);


  }




  void _initAgoreEngine(){
    AgoraRtcEngine.create(appid);
  }



  @override
  Widget build(BuildContext context){
     return new Scaffold(
       appBar: new AppBar(
         title: Text(widget.channelName),
       ),
       backgroundColor: Colors.black,
       body: new Center(
         child: Stack(
           children: <Widget>[],
         ),
       ),

     );
  }




}