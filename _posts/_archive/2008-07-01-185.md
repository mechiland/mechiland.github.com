--- 
layout: post
status: publish
type: post
published: true
title: "富客户端最佳实践之首要：异步"
---
异步操作是改善的用户体验的王道。这个原则用在富客户端开发上，显得更加重要。采用Java/.NET或者其他具备线程操作能力语言的富客户端开发提供了真正的异步执行的能力。

理解并且将这个原则贯穿于整个开发过程并不容易。异步编程往往期待一个基于回调的编程方式，这种编程方式需要在写代码的时候对可能的用户交互进行更多的思考，而不仅仅是实现功能。从编程实践上，这种方式往往牵涉到计算线程与UI绘图线程的交互操作，当有很多的操作同时出现的时候，异步先后执行的无序性也让调试和跟踪变得很麻烦。为异步代码编写测试也相当有挑战。

<strong>1. 起步</strong>

先看一个例子，界面上有一个按钮，每点击一次，界面上显示当前服务器时间。假定我们使用C#和WebService来实现这个服务器调用：

<pre lang="java">
public void button1_clicked() 
{
   DateTime serverNow = timeServiceProxy.now();
   label1.Text = serverNow;
}
</pre>

毫无疑问，这段代码是工作的。然而有个可用性问题：当这个webservice调用耗掉很多时间的时候，客户端会一直冻结住。用户感觉就像整个应用程序死掉一样。这时因为C#只有一个绘图线程——事实上，其他语言也一样。当把运算线程与绘图线程放在一起的时候，结果就是绘图线程被锁住。而消息循环往往与绘图线程在一起。消息无法循环了，自然用来响应窗口事件的各种行为如鼠标点击、窗口拖动等也就无法响应。

那么，如何改善？

很简单，将运算放到另外一个线程中。用Java实现大致如下：

<pre lang="java">
private JLabel label;
	
public void buttonClicked() {
  final Date now;
  <strong>Thread t = new Thread (new Runnable(){
    @Override
    public void run() {
        now = serviceProxy.now();
        label.setText(now.toString());
    }
			
  });</strong>
  t.start();
}
</pre>

这个基本可以工作。其原理是将运算、耗时的工作放到另外一个线程中。在Java Swing中有一些方便的类来简化这个工作，例如SwingUtilities.invokeLater和SwingUtilities.invokeAndWait. 他们都用来在不阻塞UI线程来执行运算操作，并且与UI组件进行交互的方式。.NET WPF中的Dispatcher提供了类似的功能，而BackgroundWorker提供了更细致的控制能力，我们稍后谈。

<strong>2. 反馈</strong>

仅仅将异步执行放到独立的线程执行是不够的。用户往往希望在后台进行耗时操作的时候，前端能够显示一些提示信息。最简单的提示信息是在界面上的某个地方显示“正在操作，请稍后”。

依然沿用刚才的Java代码，实现方式很简单：

<pre lang="java">
private JLabel label;
	
public void buttonClicked() {
  final Date now;
  <strong>label.setText("请稍后，正在操作...");</strong>
  Thread t = new Thread (new Runnable(){
    @Override
    public void run() {
        now = serviceProxy.now();
        label.setText(now.toString());
    }
			
  });
  t.start();
}
</pre>

基本原理就是，当开始耗时操作的时候，在某个地方显示等待消息；当操作结束后，取消等待消息。

继续，如果在进行耗时操作的时候出现异常，也应当进行相应的反馈，代码如下：

<pre lang="java">
private JLabel label;
	
public void buttonClicked() {
  final Date now;
  label.setText("请稍后，正在操作...");
  Thread t = new Thread (new Runnable(){
    @Override
    public void run() {
       try {
          now = serviceProxy.now();
       } <strong>catch(Exception ex) {
           label.setText("访问失败..");
       }</strong>
        
        label.setText(now.toString());
    }
			
  });
  t.start();
}
</pre>


<strong>3. 通用异步处理过程</strong>

上述是基本原理。然而在实际的编程中，如此原始的方式很难吸引聪明程序员的兴趣。在.NET中，提供了BackgroundWorker, 相关的API有：

<pre lang="csharp">
worker = new BackgroundWorker();
worker.DoWork += delegate(object sender, DoWorkEventArgs e) {...}
worker.RunWorkerCompleted += delegate(object sender, RunWorkerCompletedEventArgs e){...};
</pre>

BackgroundWork提供最重要的两个事件是DoWork和RunWorkerCompleted事件。前者提供了异步执行耗时运算的能力；后者为结果运算成功后与UI进行交互提供了回调，并且提供了如果运算出现异常，提供相应的异常信息。这个思路同样可以借鉴到Java以及其他的方式中。


<strong>4. 上升到框架级别</strong>

BackgroundWorker的出现可以在一定程度上通用化异步编程，然而，富客户端情况下，线程资源同样珍惜。每次新创建一个类似于BackgroundWorker类似的管理器，意味着每次都会创建新的线程。一个可以参考的思路是，自行开发一个线程池，来管理异步执行的线程。在更复杂的情况下，可以实现对于很多任务进行排列的算法。这已经超出本文的范围。当能够实现到前3步的时候，第四步的提出和实现只是时间问题。
