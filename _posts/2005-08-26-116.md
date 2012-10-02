--- 
layout: post
status: publish
type: post
published: true
title: "Why NOT javascript?"
---
我很奇怪，为什么大多数的web框架或者开发平台都试图将javascript屏蔽给开发者，以便让丝毫不懂javascript的开发者能够编写适合框架或者平台特性的应用。这样的例子很多，典型的，WEB页面的校验，Struts便集成到了自己的validation文件中，开发者不用编写javascript就能实现web表单的验证。同样，JSValidation也是完成了类似的工作。

然而，在WEB2.0时代，这种努力将会变得毫无意义。当用户体验上升成为一个优先级较高的需求时，javascript的重要性就凸现出来。用户希望更多的操作能够在同一个页面完成（in-page operation），而不是更多的表单提交刷新页面；用户希望能够在页面上拖来拽去实现自定义的页面布局，这用典型的web应用方式简直不可能实现。这个时候如果还依然试图屏蔽javascript, 试图希望不懂javascript的开发者来开发这种新型应用，简直就像不懂java而来开发J2EE（哦，现在叫Java EE）一样滑稽。

当然，使用javascript并不表示所有的js都重头开始写；已经有相当多的成熟的javascript库可供使用，这些库涵盖了web常用组件，web特效，远程调用等诸多方面，适当采用这些库，会让web开发更容易。
