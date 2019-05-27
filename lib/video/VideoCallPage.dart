
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_agore/model/VideoUserSession.dart';

class VideoCallPage extends StatefulWidget{

  //频道号 上个页面传递
  String channelName;

  VideoCallPage({Key key,this.channelName}) : super(key:key);


  @override
  State<StatefulWidget> createState(){
    return new VideoCallState();
  }
}


class VideoCallState extends State<VideoCallPage> {

  //声网sdk的appId
  String agore_appId = "6d936474d3ad4c1584a612dfebd2c529";

  //用户seesion对象
  static final _userSessions = List<VideoUserSession>();
  //是否静音
  bool muted = false;


  @override
  void initState(){
    super.initState();
    //初始化SDK
    initAgoreSdk();
    //事件监听回调
    setAgoreEventListener();


  }

  //本页面即将销毁

  @override
  void dispose(){
    _userSessions.forEach((session){
      AgoraRtcEngine.removeNativeView(session.viewId);
    });

    _userSessions.clear();
    AgoraRtcEngine.leaveChannel();
    super.dispose();
  }

  void initAgoreSdk(){
    //初始化引擎
    AgoraRtcEngine.create(agore_appId);
    //设置视频为可用 启用视频模块
    AgoraRtcEngine.enableVideo();
    //每次需要原生视频都要调用_createRendererView
    _createDrawView(0, (viewId){
    //设置本地视图。 该方法设置本地视图。App 通过调用此接口绑定本地视频流的显示视图 (View)，并设置视频显示模式。
    // 在 App 开发中，通常在初始化后调用该方法进行本地视频设置，然后再加入频道。退出频道后，绑定仍然有效，如果需要解除绑定，可以指定空 (null) View 调用
      //该方法设置本地视频显示模式。App 可以多次调用此方法更改显示模式。
      //RENDER_MODE_HIDDEN(1)：优先保证视窗被填满。视频尺寸等比缩放，直至整个视窗被视频填满。如果视频长宽与显示窗口不同，多出的视频将被截掉
    AgoraRtcEngine.setupLocalVideo(viewId, VideoRenderMode.Hidden);
    //开启视频预览
    AgoraRtcEngine.startPreview();
    //加入频道 第一个参数是 token 第二个是频道id 第三个参数 频道信息 一般为空 第四个 用户id
    AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);

    });





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
      setState(() {
        _createDrawView(uid, (viewId){
          //设置远程用户的视频视图

          AgoraRtcEngine.setupRemoteVideo(viewId, VideoRenderMode.Hidden, uid);
        });
      });

    };

    //监听用户是否离开这个房间
    AgoraRtcEngine.onUserOffline = (int uid,int reason){
      print("用户离开的id为:$uid");
      setState(() {
        _removeRenderView(uid);
      });

    };

    //监听用户是否离开这个频道
    AgoraRtcEngine.onLeaveChannel  =  (){
      print("用户离开");
    };

  }


  //创建渲染视图
  void _createDrawView(int uid,Function(int viewId) successCreate){
    //该方法创建视频渲染视图 并且添加新的视频会话对象，这个渲染视图能用在本地/远端流 这里需要更新
    //Agora SDK 在 App 提供的 View 上进行渲染。
    Widget view = AgoraRtcEngine.createNativeView(uid, (viewId){
        setState(() {
           _getVideoUidSession(uid).viewId = viewId;
           if(successCreate != null){
             successCreate(viewId);
           }
        });
    });


    //增加视频会话对象 为了视频需要(通过uid和容器信息)
    VideoUserSession videoUserSession = VideoUserSession(uid, view: view);
    _userSessions.add(videoUserSession);


  }


  //根据uid来获取session session为了视频布局需要
  VideoUserSession _getVideoUidSession(int uid){
    //满足条件的第一个元素
    return _userSessions.firstWhere((userSession){
       return userSession.uid == uid;

    });


  }

  //移除对应的用户视频节目 并且移除用户会话对象
  void _removeRenderView(int uid){
    //先从会话对象根据uid来清除
    VideoUserSession videoUserSession = _getVideoUidSession(uid);

    if(videoUserSession != null){
      _userSessions.remove(videoUserSession);
    }

    //通过引擎提供的方法来移除视频视图
    AgoraRtcEngine.removeNativeView(videoUserSession.viewId);
  }


  //以集合的形式返回视频视图
  List<Widget> _getRenderViews(){
    return _userSessions.map((session) => session.view).toList();

  }

  //单个视频视图渲染
  Widget _videoView(view){
    return Expanded(
      child: new Container(
        child: view,
      ),
    );

  }


  //最大可能占满整个布局
  Widget _createVideoRow(List<Widget> views){
    List<Widget> wrappedViews = views.map((Widget view) => _videoView(view)).toList();
    return Expanded(
      child: new Row(
        children: wrappedViews,
      ),
    );
  }


  void _switchMute(){
    setState(() {
      muted = !muted;
    });
    // true:麦克风静音 false：取消静音(默认)
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }


  //切换前后摄像头
  void _onChangeCamera(){
    AgoraRtcEngine.switchCamera();
  }

  //退出频道 退出本页面
  void _onExit(BuildContext context){
    AgoraRtcEngine.leaveChannel();
    Navigator.pop(context);

  }


  //视频视图布局
  Widget _videoLayout(){
    //先获取视频试图个数
    List<Widget> views = _getRenderViews();

    switch(views.length){
      //只有一个用户的时候 整个屏幕
      case 1:
        return new Container(
          child: new Column(
            children: <Widget>[
              _videoView(views[0])
            ],
          ),
        );

      //两个用户的时候 上下布局 自己在上面 对方在下面
      case 2:
        return new Container(
          child: new Column(
            children: <Widget>[
              _createVideoRow([views[0]]),
              _createVideoRow([views[1]]),
            ],
          ),
        );

      //三个用户
      case 3:
        return new Container(
          child: new Column(
            children: <Widget>[
              //截取0-2 不包括2 上面一列两个 下面一个
              _createVideoRow(views.sublist(0, 2)),

              //截取2 -3 不包括3
              _createVideoRow(views.sublist(2, 3))
            ],
          ),
        );

      //四个用户
      case 4:
         return new Container(
           child: new Column(
             children: <Widget>[
               //截取0-2 不包括2 也就是0,1 上面 下面各两个用户
               _createVideoRow(views.sublist(0, 2)),

               //截取2-4 不包括4 也就是 3,4
               _createVideoRow(views.sublist(2, 4))
             ],
           ),
         );
      default:
    }
    return new Container();
  }

  //底部的菜单栏
  Widget _bottomToolBar(){
    //再中央
    return Container(
      alignment: Alignment.bottomCenter,
      //竖直方向相隔48
      padding: EdgeInsets.symmetric(vertical: 48),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //静音按钮
          RawMaterialButton(
            //点击事件
            onPressed: (){
              return _switchMute();
            },

            child: new Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size : 20.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor:  muted ? Colors.blueAccent : Colors.white,
            padding:  const EdgeInsets.all(12.0),
          ),


          //挂断按钮
          RawMaterialButton(
            onPressed: (){
              return _onExit(context);
            },
            child: new Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),

          //前后摄像切换
          RawMaterialButton(
            onPressed: () => _onChangeCamera(),
            child: new Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),

    );
  }



  @override
  Widget build(BuildContext context){
     return new Scaffold(
       appBar: new AppBar(
         title: Text(widget.channelName),
       ),
       body: new Center(
         child: Stack(
           children: <Widget>[_videoLayout(),_bottomToolBar()],
         ),
       ),

     );
  }




}