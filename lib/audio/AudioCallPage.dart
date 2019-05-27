import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_agore/model/VideoUserSession.dart';

class AudioCallPage extends StatefulWidget {
  //频道号 上个页面传递
  String channelName;

  AudioCallPage({Key key, this.channelName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AudioCallPageState();
  }
}

class AudioCallPageState extends State<AudioCallPage> {
  //声网sdk的appId
  String agore_appId = "6d936474d3ad4c1584a612dfebd2c529";

  //用户seesion对象
  static final _userSessions = List<VideoUserSession>();

  //是否静音
  bool muted = false;

  //是否启用扬声器
  bool speakPhone = false;

  //对方的uid
  int self_uid;


  @override
  void initState() {
    super.initState();
    //初始化SDK
    initAgoreSdk();
    //事件监听回调
    setAgoreEventListener();
  }

  //本页面即将销毁
  @override
    void dispose() {
    //把集合清掉
    _userSessions.clear();
    AgoraRtcEngine.leaveChannel();
    //sdk资源释放
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  //创建渲染视图
  void _createRendererView(int uid) {
    //增加音频会话对象 为了音频布局需要(通过uid和容器信息)
    //加入频道 第一个参数是 token 第二个是频道id 第三个参数 频道信息 一般为空 第四个 用户id
    setState(() {
      AgoraRtcEngine.joinChannel(null, widget.channelName, null, uid);
    });

    VideoUserSession videoUserSession = VideoUserSession(uid);
    _userSessions.add(videoUserSession);
    print("集合大小"+_userSessions.length.toString());
  }

  //根据uid来获取session session为了视频布局需要
  VideoUserSession _getVideoUidSession(int uid) {
    //满足条件的第一个元素
    return _userSessions.firstWhere((userSession) {
      return userSession.uid == uid;
    });
  }

  //移除对应的用户界面 并且移除用户会话对象
  void _removeRenderView(int uid) {
    //先从会话对象根据uid来清除
    VideoUserSession videoUserSession = _getVideoUidSession(uid);

    if (videoUserSession != null) {
      _userSessions.remove(videoUserSession);
    }
  }

  void initAgoreSdk() {
    //初始化引擎
    AgoraRtcEngine.create(agore_appId);
    //设置视频为可用 启用音频模块
    AgoraRtcEngine.enableAudio();
    //每次需要原生视频都要调用_createRendererView
    _createRendererView(0);
  }

  //设置事件监听
  void setAgoreEventListener() {
    //成功加入房间
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      print("成功加入房间,频道号:${channel}+uid+${uid}");

    };

    //监听是否有新用户加入
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      print("新用户所加入的id为:$uid");

      setState(() {
        //更新UI布局
        _createRendererView(uid);
        self_uid = uid;
      });
    };

    //监听用户是否离开这个房间
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      print("用户离开的id为:$uid");
      setState(() {
        //移除用户 更新UI布局
        _removeRenderView(uid);
      });
    };

    //监听用户是否离开这个频道
    AgoraRtcEngine.onLeaveChannel = () {
      print("用户离开");
    };
  }

  //以集合的形式返回音频视图
  List<int> _getRenderViews() {
    return _userSessions.map((session) => session.uid).toList();
  }

  //开关本地音频发送
  void _isMute() {
    setState(() {
      muted = !muted;
    });
    // true:麦克风静音 false：取消静音(默认)
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  //是否开启扬声器
  void _isSpeakPhone() {
    setState(() {
      speakPhone = !speakPhone;
    });
    AgoraRtcEngine.setEnableSpeakerphone(speakPhone);
  }

  //退出频道 退出本页面
  void _onExit(BuildContext context) {
    AgoraRtcEngine.leaveChannel();

    Navigator.pop(context);
  }


  //音频布局视图布局
  Widget _viewAudio() {
    //先获取音频人数
    List<int> views = _getRenderViews();
    switch (views.length) {
      //只有一个用户(即自己)
      case 1:
        return Center(
          child: Container(
            child: Text("用户1"),
          ),
        );
      //两个用户
      case 2:
        return Positioned(//在中间显示对方id
          top: 180,
          left: 30,
          right: 30,
          child: Container(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    width: 140,
                    height: 140,
                    color: Colors.red,
                    child: Text("对方用户uid:\n${self_uid}",
                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      default:
    }
    return new Container();
  }

  //底部的菜单栏
  Widget _bottomToolBar() {
    //在中央
    return Container(
      alignment: Alignment.bottomCenter,
      //竖直方向相隔48
      padding: EdgeInsets.symmetric(vertical: 48),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //是否静音按钮
          RawMaterialButton(
            //点击事件
            onPressed: () {
              return _isMute();
            },

            child: new Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),

          //挂断按钮
          RawMaterialButton(
            onPressed: () {
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

          //是否外放
          RawMaterialButton(
            onPressed: () => _isSpeakPhone(),
            child: new Icon(
              speakPhone ? Icons.leak_remove : Icons.leak_add,
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
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.channelName),
      ),
      //背景黑色
      backgroundColor: Colors.black,
      body: new Center(
        child: Stack(
          children: <Widget>[_viewAudio(), _bottomToolBar()],
        ),
      ),
    );
  }
}
