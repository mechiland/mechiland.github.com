--- 
layout: post
status: publish
type: post
published: true
title: "为什么BaseCamp Next如此之快？"
---

37Signals的新产品Basecamp Next将要现身了。作为他们一贯的市场手段之一，预先的演练自然是必不可少的。但与之前的口水文字不同，最近几天的blog非常详细的将他们的下一代产品的界面、交互以及各种技术细节做了讲解。（如果你还不知道Basecamp Next，请翻墙，[全屏看这篇Blog](http://37signals.com/svn/posts/3111-basecamp-next-ui-preview)）

新的UI看起来很酷。从项目、到TODO跟踪、讨论，这些功能看起来就像是在一页页的纸翻过去翻过来一样。页面响应也非常快⋯⋯是非常快，在你注意不到的等待时间里，各种页面就进行了转换。

常见的猜测是，这是一个One Page Application，试用诸如BackboneJS之类的客户端MVC框架，服务器端仅仅提供JSON/XML的内容，所有的逻辑放在客户端，通过Javascript来渲染处理。我也是这么猜测的。但从后续的几篇文章看来，完全不是这样：他们采用的中规中矩的Rails技术，通过key-value缓存，加上pjax的局部刷新来实现。以下实现要点。不得不说，这些实现手法充分利用了现有技术的优势，几乎没有重新造轮子，而产生了令人惊叹的结果。

* 用了很多内存⋯⋯[很多很多](http://37signals.com/svn/posts/3090-basecamp-nexts-caching-hardware)内存。864GB，耗费一万两千刀($12,000)。

* 采用Memcached，缓存⋯⋯所有的东西（既然有864GB内存，就应该用干净嘛）。Redis也用了，但只是用在Resque队列中

* 令人头痛的缓存更新策略问题，则通过ActiveRecord#cache_key作为缓存主键解决。不得不说，这个方法的确很巧妙。在大多数缓存场景里，cache key是稀缺资源，往往指定了一个cache key之后，剩下的事情就是考虑如果更新它的内容。换句话说，key是不变的，content不断的变化。而在Basecamp Next新的设计中，刚好反过来，key是临时的。。。content是固定的。一旦一个ActiveRecord对象发生变化，那么key也发生变化，页面直接使用新的key，旧的key被无情抛弃，利用memcached的LRU能力，自动删除旧的内容。实现非常简单，ActiveRecord#cache_key早就有了，memcached LRU工作得很健壮。（[具体请看这里](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)）

* 前端其实没什么。有了这么变态的后台，像Basecamp这种读操作大于写操作的应用，前台即便什么都不做，都会快的惊人。但前端还是有亮点。[pjax](https://github.com/defunkt/jquery-pjax) ，其实本质是[HTML5 pushState](http://diveintohtml5.info/history.html)技术的使用，让前台界面只需要加载一次模板、数目众多的Javascript和CSS。现在JQuery的[on](http://api.jquery.com/on/)操作也很强大，能够在元素还没有创建的时候挂接事件，这样每次服务器往返的开销降到了最低。在我自己的试验Rails应用中，采用[pjax-rails](http://rubygems.org/gems/pjax-rails)插件，那链接跳转速度，快得让你不敢相信。貌似37Signals[自己编写了一个框架Stacker](http://37signals.com/svn/posts/3112-how-basecamp-next-got-to-be-so-damn-fast-without-using-much-client-side-ui)，估计能够更高级的处理pjax带来的其他问题，特别是联动状态的处理。

最令人佩服的是——实现这些看起来很酷的结果都是采用已知的技术，没有什么火箭科技，也没有什么取巧的黑客手法。现在的考验就来自于真实的产品环境，在更多的用户情况下是否会出现其他未知的问题。

