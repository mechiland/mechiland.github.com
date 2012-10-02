--- 
layout: post
status: publish
type: post
published: true
title: "对buffalo进行了一些改进"
---
加入了ServiceRepository类，用来保持BuffaloService实例。ServiceRepository中包含了一系列用来注册Service的方法，包括从字符串，Class, 实例中获取Service实例。但随之而来的出现一个问题，该如何控制这些BuffaloService的生命周期？

在1.0alpha版中，buffalo只是简单的通过反射生成实例，每一个请求生成一个，这种规则简单而容易掌握；然而，一旦通过ServiceRepository来控制，那么服务实例的创建该如何创建？是单例，实例池，还是每次都新创建？这是个问题。想着想着，ServiceRepository最后可能变成简单的组件管理容器了，那么在创建的时候，可能就会有一个形如hivemind或者Spring配置文件的东东，描述这个service应该如何产生(singleton,pooled,instance...). 这种复杂性无论是我，还是使用者，都不想看到的。因此，我决定只在ServiceRepository中保留要运行实例的类名，单独使用buffalo的应用将只通过反射来产生新实例；而将这些应用生命周期的管理，交给Spring集成Buffalo来控制。

加入了ServiceRepository类后定义buffalo service更为灵活，不用受限制在buffalo-service.properties中了。

客户端也进行了增强，现在客户端能够将应用对象作为参数发送到服务器端了。参考代码如下：

	var u = {};
	u[Buffalo.BOCLASS] = "net.buffalo.demo.simple.User";
	u.id = 234;
	u.name = "Julie";
	u.age = 17;
	u.sex = true;
	u.memo = "very beautiful";

	buffalo.remoteCall("tutorialService.hash",[u], function(reply) {
		alert(reply.getResult());
	});

当然，目前只能发送简单对象，主要是为了满足特定应用的要求，对于复杂对象（包括对象间相互引用）是否需要加入还在进一步考虑中。

以上特性将在1.1版中支持。另外，1.2版中还打算支持JDK5.0的注解（Annotation）。
