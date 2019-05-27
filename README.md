## 一、前言
今天用声网提供的Flutter插件**声网Agore**来简单实现体验音视频功能。首先前往[声网官网](https://www.agora.io/cn/)看看大致介绍：


![声网介绍](https://user-gold-cdn.xitu.io/2019/5/23/16ae4bfa4cd15f9b?w=1980&h=1104&f=png&s=280672)可以看到**声网sdk**支持语音通话，视频通话和互动直播，接着点击**立即体验**注册账号和创建项目，目的是获取**App ID**，最后在项目详情能看到项目名字，App ID，项目状态，创建时间，应用证书，信令令牌调试开关等：

![声网项目信息](https://user-gold-cdn.xitu.io/2019/5/23/16ae4c62f1ec860d?w=1284&h=742&f=png&s=77343)
目前对我最有用的是**App ID**，其他可以先忽略。

## 二、依赖插件
因为我是用Flutter来实现，因此**声网插件**应该在[https://pub.dev/packages/](https://pub.dev/packages/)上，搜索Agore，可以看到：

![Flutter声网插件](https://user-gold-cdn.xitu.io/2019/5/23/16ae4d39c5a6270a?w=691&h=829&f=png&s=107406)


从上面信息可以知道声网的插件叫**agora_rtc_engine**，版本是0.9.5，**Agore.io**提供构建模块，通过SDK添加实时语音和视频通信。另外简单说了用法，一些所必要权限和注意事项，下面直接依赖此插件进行开发，首先在`pubspec.yaml`文件下添加依赖：

![依赖声网插件](https://user-gold-cdn.xitu.io/2019/5/23/16ae4de612b02e08?w=1558&h=669&f=png&s=208461)
可以看到我还依赖了权限库和吐司库，目的是为了动态申请权限和弹出提示。

## 三、项目结构

![项目结构](https://user-gold-cdn.xitu.io/2019/5/23/16ae53544200f1f5?w=448&h=187&f=png&s=27679)


整个demo例子结构很简单，主要是四个Dart文件：分别是视频语音对象，首页，语音页，视频页。

### 1.首页
首页布局很简单，就两个按钮，分别是语音通话和视频通话，先上草图：

![首页草图](https://user-gold-cdn.xitu.io/2019/5/23/16ae54eb97bb8210?w=432&h=409&f=png&s=15739)


根布局是`Center`，孩子是`Row`，`Row`里分别是左右排列的`RaisedButton`按钮，代码具体如下：
```java
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,//主轴空白区域均分
          children: <Widget>[
            //左边的按钮
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
            //右边的按钮
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
```


效果如下：

![首页布局](https://user-gold-cdn.xitu.io/2019/5/23/16ae542c3907ebfa?w=538&h=896&f=png&s=33295)


下面实现点击事件，逻辑很简单，首先是要授予权限(权限用simple_permissions这个库)，权限授予之后再进入相应的页面：
* 语音点击事件`onAudio()`
```java
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
```
语音只授予录音权限即可。

* 视频通点击事件`onVideo()`
视频需要授予的权限多了相机权限而儿：
```java
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
```
这样首页算完成了。

### 2.语音页面(AudioCallPage)
这里我只做了一对一语音通话的界面效果，也可以实现多人通话，只是把界面样式改成自己喜欢的样式即可。
#### 2.1.样式
一对一通话的界面类似微信语音通话界面一样，屏幕中间是对方头像(这里我只显示对方用户ID)，底部是菜单栏：是否静音，挂断，是否外放，草图如下：

![一对一通话样式草图](https://user-gold-cdn.xitu.io/2019/5/24/16aea29b4f6ae81c?w=539&h=448&f=png&s=21640)


主要用`Stack`层叠控件+`Positioned`来定位：
```java
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
```
#### 2.2.逻辑
实现语音主要五个步骤，分别是：
* 初始化引擎
* 启用音频模块
* 创建房间
* 设置事件监听(成功加入房间，是否有用户加入，用户是否离开，用户是否掉线)
* 布局实现
* 退出语音(根据需要销毁引擎，释放资源)

##### 2.2.1.初始化引擎
初始化引擎只有一句代码：
```java
    //初始化引擎
    AgoraRtcEngine.create(agore_appId);
```
进去源码发现：
```java
  /// Creates an RtcEngine instance.
  ///
  /// The Agora SDK only supports one RtcEngine instance at a time, therefore the app should create one RtcEngine object only.
  /// Only users with the same App ID can join the same channel and call each other.
  //在RtcEngine SDK的应用程序应该只创建一个RtcEngine实例
  static Future<void> create(String appid) async {
    _addMethodCallHandler();
    return await _channel.invokeMethod('create', {'appId': appid});
  }

```
发现里面还调用例`_addMethodCallHandler`方法，忘看看里面：
```java
// CallHandler
  static void _addMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map values = call.arguments;

      switch (call.method) {
        // Core Events
        case 'onWarning':
          if (onWarning != null) {
            onWarning(values['warn']);
          }
          break;
        case 'onError':
          if (onError != null) {
            onError(values['err']);
          }
          break;
        case 'onJoinChannelSuccess':
          if (onJoinChannelSuccess != null) {
            onJoinChannelSuccess(
                values['channel'], values['uid'], values['elapsed']);
          }
          break;
        case 'onRejoinChannelSuccess':
          if (onRejoinChannelSuccess != null) {
            onRejoinChannelSuccess(
                values['channel'], values['uid'], values['elapsed']);
          }
          break;
          ......
          }
     }
     
  }
```
可以看到主要是特定触发条件的回调，如：SDK错误，是否成功创建频道，是否离开频道等，那么现在可以知道`AgoraRtcEngine.create(agore_appId)`这行代码是初始化引擎和实现某些状态下的监听回调。

##### 2.2.2.启用音频模块
启用音频模块：
```java
    //设置视频为可用 启用音频模块
    AgoraRtcEngine.enableAudio();
```
看官方文档介绍：

![启用音频模块](https://user-gold-cdn.xitu.io/2019/5/27/16af981b67995477?w=1462&h=748&f=png&s=164039)

##### 2.2.3.加入房间
当初始化完引擎和启用音频模块后，下面进行创建房间：
```java
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
```
主要看`AgoraRtcEngine.joinChannel(null, widget.channelName, null, uid);`这个方法：

![加入声音频道](https://user-gold-cdn.xitu.io/2019/5/27/16af98de898d3baa?w=1898&h=1008&f=png&s=243973)
第一个参数是服务器生成的token，第二个参数是声音的频道号，第三个参数是频道的信息，第四个参数是用户的uid，我这边传0，sdk会自动分配。另外注意我这边用`VideoUserSession`类来管理用户信息，通过集合`List<VideoUserSession>`来存放当前在房间的人数，目的就是为了布局方便。

##### 2.2.4.设置事件的监听
当如果有用户新加入进来，或者用户离开又或者是掉线，我们能不能知道呢？答案是肯定的：
```java
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
```
##### 2.2.5.布局实现
下面简单实现屏幕中间的UI实现，我这边只做了一对一通话，也就是中间只显示对方的用户id，如果多人通话，也可以根据`List<VideoUserSession>`的数量依次显示。
```java
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
```
上面主要是根据`List<VideoUserSession>`集合自己控制语音通过页面。

##### 2.2.6.退出语音
如果用户退出本界面或者挂断，必须调用`AgoraRtcEngine.leaveChannel();`：
```java
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
```
当有用户离开了这个房间后，会回调`AgoraRtcEngine.onUserOffline`这个方法，文档也有说明：

![用户掉线](https://user-gold-cdn.xitu.io/2019/5/27/16af9a96e4173569?w=2008&h=1086&f=png&s=275030)
文档清晰说明当用户主动离开或者掉线都会回调这个方法，我通过这个方法来实现当用户退出房间后(移除用户会话对象)UI更新效果：
```java
  //移除对应的用户界面 并且移除用户会话对象
  void _removeRenderView(int uid) {
    //先从会话对象根据uid来清除
    VideoUserSession videoUserSession = _getVideoUidSession(uid);

    if (videoUserSession != null) {
      _userSessions.remove(videoUserSession);
    }
  }
```

##### 2.2.7.是否静音
是否静音是通过`AgoraRtcEngine.muteLocalAudioStream(muted);`方法来实现：
```java
  //开关本地音频发送
  void _isMute() {
    setState(() {
      muted = !muted;
    });
    // true:麦克风静音 false：取消静音(默认)
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }
```

##### 2.2.8.是否开扬声器
```java
  //是否开启扬声器
  void _isSpeakPhone() {
    setState(() {
      speakPhone = !speakPhone;
    });
    AgoraRtcEngine.setEnableSpeakerphone(speakPhone);
  }
```

#### 2.3.最终效果

![压缩后的声音效果](https://user-gold-cdn.xitu.io/2019/5/27/16af9d7e8ae8147b?w=540&h=944&f=gif&s=4969325)


因为是gif，所以听不见声音，上面还有两个小问题要完善的：
* 一对一通话应该是双方连接才能进入通话界面
* 当一方退出后，另一方也应该退出

### 3.视频页面(VideoCallPage)
这里视频支持多人视频，工具栏也和语音一样，也是在底部，当和一对一对方视频通话时，屏幕分为两部分，上面是自己，下面是对方的视频，其他逻辑和语音基本一致，实现视频主要有四个步骤：
* 初始化引擎
* 启用视频模块
* 创建视频渲染视图
* 设置本地视图
* 开启视频预览
* 加入频道
* 设置事件监听

#### 3.1.启用视频

启用视频模块主要也是一句代码`AgoraRtcEngine.enableVideo();`，看文档说明：

![启用视频模块](https://user-gold-cdn.xitu.io/2019/5/27/16af9ebc54cb0b36?w=1948&h=874&f=png&s=221690)
主要意思是可以在加入频道之前或通话期间调用此方法。

#### 3.2.创建视频渲染视图
创建视频播放插件：
```java

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
```

也是通过集合来存放管理会话对象信息，就是为了方便视频布局。

#### 3.3.设置本地视图

![设置本地视图](https://user-gold-cdn.xitu.io/2019/5/27/16af9f44745fb547?w=1972&h=932&f=png&s=176818)
官方文档的意思是设置本地视频视图并配置本地设备上的视频显示设置：
```java
    //设置本地视图。 该方法设置本地视图。App 通过调用此接口绑定本地视频流的显示视图 (View)，并设置视频显示模式。
    // 在 App 开发中，通常在初始化后调用该方法进行本地视频设置，然后再加入频道。退出频道后，绑定仍然有效，如果需要解除绑定，可以指定空 (null) View 调用
    //该方法设置本地视频显示模式。App 可以多次调用此方法更改显示模式。
    //RENDER_MODE_HIDDEN(1)：优先保证视窗被填满。视频尺寸等比缩放，直至整个视窗被视频填满。如果视频长宽与显示窗口不同，多出的视频将被截掉
    AgoraRtcEngine.setupLocalVideo(viewId, VideoRenderMode.Hidden);
```
并且制定视频渲染模式。

#### 3.4.开启视频预览

![开启视频预览](https://user-gold-cdn.xitu.io/2019/5/27/16af9f9ea2bd3ce5?w=1866&h=888&f=png&s=159145)
加入频道之前启动本地视频预览，当然调用此方法之前，必须调用`setupLocalVideo`和`enableVideo`。

#### 3.5.加入频道
当一切准备就绪后就要加入视频房间，加入视频房间和加入语音房间是一样的：
```java
    //加入频道 第一个参数是 token 第二个是频道id 第三个参数 频道信息 一般为空 第四个 用户id
    AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
```
#### 3.6.设置事件监听
设置事件监听视频和语音最大一点不一样就是，多了设置远程用户的视频视图，这个方法主要是此方法将远程用户绑定到视频显示窗口（为指定的远程用户设置视图uid）。

![远程用户的视频视图](https://user-gold-cdn.xitu.io/2019/5/27/16afa0468feb62a4?w=1906&h=930&f=png&s=248921)
这个方法要在用户加入的回调方法中调用：
```java
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
```

#### 3.7.布局实现
这里要分情况，1-5各用户的情况：
```java
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
```
最核心的就是，有用户退出和加入就要更新UI视图。

#### 3.8.最终效果

![视频效果](https://user-gold-cdn.xitu.io/2019/5/28/16afa178d171cc58?w=540&h=944&f=gif&s=4956817)


最终效果如上图，前后摄像头切换，挂断和静音的功能效果没录进去。

## 四、总结
* 整体开发来看并不是很难，按照具体的文档来做，普通的一些功能是能实现的，当然如果后面做一些比较高级的功能就要花多一点心思去研究。
* 语音，视频效果还是不错的。
* 有具体的详细开发，有文档开发者社区，便于开发者交流，反馈使用过程中的问题，这一点是非常nice的。
* 另外，在ios模拟器是运行不了的，报的错误是：pod not install，找了很多资料没解决。。。

## 五、参考资料
* [声网开发者文档](https://dashboard.agora.io/)
* [构建你的第一个Flutter视频通话应用](https://juejin.im/post/5c6f89ece51d456598092ce6)
