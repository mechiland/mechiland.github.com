--- 
layout: post
status: publish
type: post
published: true
title: "实现类似于rails的web开发框架"
---
Rails的成功依赖于以下几点：

<strong>1</strong> Web应用多年来积累的各种常见约定，convention over configuration. 这是rails简单的最根本保证。Rails将常见的一些配置信息从繁杂的xml配置文件中解脱出来，成为命名约定。这样xml的配置大大减少。

在目前几乎所有的MVC框架将xml作为配置的方式。而对于领域对象增删改查，rails采用如下的命名约定：

	domainObject/view/id
	domainObject/edit/id
	domainObject/list
	…

2 简单的Ruby语言。这也是rails成功的原因之一。

3 强大的代码生成器。加快开发速度的技巧之一，是将相同特征的操作利用代码生成机制完成大多数功能。这里不仅仅是业务代码，而且包括那些页面。页面能够根据数据库字段类型，生成相应的录入或者修改的输入框。

4 基于活动记录(ActiveRecord)的O/R映射

以上任何一个特征，采用java领域的相关知识都不难实现。那么，我们现在来看一下，如何实现这样一个特征的web框架。

<strong>基本思路</strong>

采用一个Servlet对所有的请求进行转发，路径中包括了要操作的domain object, 什么操作，以及操作所需的参数，因此，得到这些信息后，找到相应的domain object，并实例化；利用语言本身提供的反射（或称内省）特征，找到对应的方法，然后执行；将执行的结果返回到某一种界面表现中，然后显示。

大概思路就是这样，我们来看一下，在java世界里，这样的一套东西如何实现。

场景：/app/UserInfo/edit/1
编辑ID=1的用户信息。
基本路径配置：所有应用相关的文件都放在WEB-INF/app中，里面文件排放规则类似于rails，遵循MVC模式：controllers中存放控制器，views中按照domain object分别存放各种操作对应的页面（如增删改查），models中存放domain object定义。

由于在URL中保留了足够的对象、操作以及参数的各种信息，这些信息可以很容易的被获取：

<strong>1 获得对应的路径信息</strong>

	String path = request.getPathInfo();
	String[] args = path.split(“/”);
	String domainObject = args[1]; // UserInfo
	String operation = args[2] // edit
	//…others are parameters // id=1

<strong>2 根据信息，找到相应的domain object. </strong> 按照rails的设计思路，这里需要最好采用某种脚本语言来实现。当然，在大型应用中，我们可以直接引用已经设计好的domain object, 但在这里，我们可以直接在某一种脚本语言中编写。jvm内的脚本语言种类繁多，你有足够多的选择：JavaScript, Python, Groovy等等，只需要选一种自己熟悉的就可以了；如果对纯粹的java更感兴趣，可以直接使用BSH（事实上，这就是大名鼎鼎的OFBiz的表现逻辑的做法）。这里我们使用Jython: 

	def class UserInfoController:
		def edit(self,id):
			objectMapper.edit(selfProerpties, id) # 这是伪代码，你可以有足够多的选择来更新对象
			return {“object”:self}

<strong>3 Servlet通过某种方式来调用这段代码，并将结果返回给Servlet. </strong>

	interpreter.execfile(theActionFile);
	PyObject cls = interp.get(domainObject+”Controller”);
	PyInstance controller = (PyInstance)cls.__call__();
	PyDictionary pr = (PyDictionary)controller.invoke(operation, args);
	Map map = Utils.PyDict2JavaMap(pr);

<strong>4 获得结果后，进行展现。</strong>下面就是某一种表现端一展身手的地方了: 
许多模版语言都依赖于某一种类似于Map的数据结构来提供数据，这里以FreeMarker为例：

	cfg = Configuration.getDefaultConfiguration();
	cfg.setServletContextForTemplateLoading(getServletContext(), "WEB-INF/app/views");
	Template t = cfg.getTemplate(domainObject+”/”+operation+”.ftl”);
	t.process(map, response.getWriter());

对于velocity，也可以进行同样的处理；而如果你更习惯于jsp, 则完全可以将Map中的数据放置到request中，然后输出jsp, 在jsp中使用JSTL对数据进行使用：

	for (Map.Entry entry : map) {
		request.setAttribute(entry.getKey().toString(), entry.getValue());
	}
	request.getRequestDispatcher("views/"+ domainObject+”/”+operation+”.jsp”).forward(request, response)

这样，一个类似于Rails思想的Web框架就完成了. 当然，这里面还有需要需要细化的地方，许多代码需要推敲，在生产环境中，还有更多类似于缓存等需要注意的地方。O/R映射也没有提及，代码生成也需要进行考虑。但是无论如何，有了这样的思路，实现一个类似的web框架不是难事了。

[update] 这样的一种框架到底在什么地方使用最好呢？我的体会是在小型应用中，尽可能采用这样的轻型方式。在我目前参与的项目中，有时需要一些小型的web应用来辅助开发，这些小型应用的特点是需求紧急，需要马上使用；传统的j2ee开发肯定不能使用——等到domain object设计出来，已经不需要了；而其他的编程语言可能不是太方便；直接用jsp可以，但是不能清晰区分数据与表现，还是不佳。因此这样一种方式是比较好的——一旦设计完成，只需要编写python文件，放到特定目录即可。

另外，在大型应用中，对于服务层外围程序的开发，也可以采用这种方式。OFBiz就是这样做的，服务层内部采用普通java代码开发；web层与应用层之间的结合采用bsh脚本。这样，当需要调整页面或者添加改动量不大的新业务时，无需编译，编写出来马上就可以看到效果了。因此，采用传统j2ee方式构建服务层以及内核，采用脚本程序进行外部开发，结合了编译与运行的双重优势，这种方式值得使用。

关于脚本语言，我个人偏好python, 但在java领域，你有太多的选择：Groovy, ruby, javascript等等。
