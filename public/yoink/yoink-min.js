var YOINK=(function(){var Module=function(deps,f){this.deps=deps;this.func=f};var defaultInterpreters={json:function(text){return JSON.parse(text)},js:function(text,yoink,callback){var f=eval("(function () {"+text+"})");var mod=f();if(mod&&mod.constructor===Module){yoink(mod.deps,function(){callback(mod.func.apply(null,arguments))})}else{callback(mod)}},};var clone=function(o1){var o2={};for(k in o1){o2[k]=o1[k]}return o2};var ResourceLoader=function(base,cache,interpreters){this.base=base||"";this.cache=cache||{};this.interpreters=interpreters||clone(defaultInterpreters);return this};ResourceLoader.prototype={interpret:function(rsc,url,interpreter,getResources,callback){if(!interpreter){var ext=url.substring(url.lastIndexOf(".")+1,url.length).toLowerCase();interpreter=this.interpreters[ext]||function(x){return x}}if(interpreter.length===1){callback(interpreter(rsc))}else{var base=url.substring(0,url.lastIndexOf("/"));var subloader=new ResourceLoader(base,this.cache,this.interpreters);var yoink=function(urls,f){return getResources.call(subloader,urls,f)};interpreter(rsc,yoink,callback)}},resolve:function(url){var p=url.path||url;var f=url.interpreter||null;if(this.base!==""&&p[0]!=="/"&&p.indexOf("://")===-1){p=this.base+"/"+p}return{path:p,interpreter:f}},getResourceSync:function(url){url=this.resolve(url);var rsc=this.cache[url.path];if(rsc===undefined){var req=new XMLHttpRequest();req.open("GET",url.path,false);req.send();var getResources=function(urls,callback){var rscs=this.getResourcesSync(urls);callback.apply(null,rscs)};this.interpret(req.responseText,url.path,url.interpreter,getResources,function(r){rsc=r});this.cache[url.path]=rsc}return rsc},getResourcesSync:function(urls){var rscs=[];var len=urls.length;for(var i=0;i<len;i++){rscs[i]=this.getResourceSync(urls[i])}return rscs},getResource:function(url,callback){url=this.resolve(url);var rsc=this.cache[url.path];if(rsc===undefined){var req=new XMLHttpRequest();var loader=this;req.onreadystatechange=function(){if(req.readyState===4){var getResources=function(urls,callback){this.getResources(urls,callback)};loader.interpret(req.responseText,url.path,url.interpreter,getResources,function(rsc){loader.cache[url.path]=rsc;callback(rsc)})}};req.open("GET",url.path,true);req.send()}else{setTimeout(function(){callback(rsc)},0)}},getResources:function(urls,callback){var rscs=[];var cnt=0;var len=urls.length;var mkHandler=function(i){return function(rsc){rscs[i]=rsc;cnt++;if(cnt===len){callback.apply(null,rscs)}}};for(var i=0;i<len;i++){this.getResource(urls[i],mkHandler(i))}},};function resourceLoader(base,cache,interpreters){return new ResourceLoader(base,cache,interpreters)}function module(deps,f){return new Module(deps,f)}return{resourceLoader:resourceLoader,module:module,interpreters:defaultInterpreters,}})();