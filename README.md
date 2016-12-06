#### 为什么要写这么一个插件？
毫无疑问，使用插件就是提高开发效率。将一些毫无套路的，特定格式的代码集合在一个工具里面，需要的时候直接使用快捷键将它们呼唤出来。

#### 运行平台
这是一款基于 Objc 的 Getter 函数自动补全插件，基于 Xcode 8 的 Source Editor Extension 开发。

#### 效果图：
![效果演示.gif](http://upload-images.jianshu.io/upload_images/959078-16fc9ba7af3f6439.gif?imageMogr2/auto-orient/strip)

#### 用法：
1. 选择 `AutomaticCompletion` 运行，如下图</br>
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/959078-60201edd5c247715.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/959078-29e949d139b0c70a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 之后会弹出一个黑色的Xcode，如下。</br>
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/959078-d75d21423525c23e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
</br>在右侧选择项目打开。

3. 将光标移动到需要补全 Getter 函数的位置，在Xcode中选择`Editor->AutomaticCompletion->Source Editor Command`进行补全，如下图</br>
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/959078-d008d3bd2a18ff94.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 快捷键设置
在用户偏好设置里面选择`Key Bindings`，输入`AutomaticCompletion` 使用自定义快捷键
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/959078-f98f2302c34ce358.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 注意事项：
1. 插件使用的证书要和项目的证书要一致。
2. 如果如果你的Xcode是运行在 OS X 10.11 El Capitan的话，打开Terminal，执行下面的命令，然后重启Mac。</br>`sudo /usr/libexec/xpccachectl`
3. 目前是特定的格式，还没实现自定义模版，有特定需求的朋友可以`clone`一份我的代码，然后改成自己特定的格式。
4. 每次都需要先运行插件，然后在黑色 Xcode 中运行项目，使用插件，网上也有人说，将编译之后的`appex`放到`/Applications/Xcode.app/Contents/PlugIns`，我测试了一下，发现行不通。

代码写的low，望各位大神勿喷。有问题的可以提[issue](https://github.com/CYBoys/AutomaticCompletionPlugin/issues/new)
如果觉得不错，请赏赐一个 star 支持一下！😘

