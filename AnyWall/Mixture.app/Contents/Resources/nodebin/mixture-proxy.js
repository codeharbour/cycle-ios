function proxy(e,t,r){var a={}
a.host=argTargetHostname,a.port=argTargetPort,a.path=e.url,a.headers=e.headers,a.headers.host=target
var s=void 0===e.connection.encrypted?"http://":"https://"
a.uri=s+target+e.url,a.cookie=e.cookie,delete a.headers["accept-encoding"],a.method=e.method
var o=request(a)
return o.on("response",r),o}var http=require("http"),httpProxy=require("http-proxy"),url=require("url"),fs=require("fs")
request=require("request"),uglify=require("uglify-js"),net=require("net")
var argListenHostname=process.argv[2],argListenPort=process.argv[3],argTargetHostname=process.argv[4],argTargetPort=process.argv[5],argWebSocket=process.argv[6],argsPathToNodeJs=process.argv[7],argsLeader=process.argv[8],argsDebug=process.argv[9]
argsLeader="false"==argsLeader?"false":"true"
var sockparts=argWebSocket.split(":"),hosts=[[sockparts[0],sockparts[1]]]
setInterval(function(){hosts.forEach(function(e){var t=new net.Socket
t.setTimeout(2500),t.on("connect",function(){t.destroy()}).on("error",function(){process.exit(1)}).on("timeout",function(){process.exit(1)}).connect(e[1],e[0])})},5e3)
var target=argTargetHostname+":"+argTargetPort,target80=argTargetHostname,listen=argListenHostname+":"+argListenPort,lguid="00000000-0000-0000-0000-000000000000",lurl,liveRefreshScript
fs.readFile(argsPathToNodeJs+"/live-refresh.js","utf8",function(e,t){liveRefreshScript=t.replace("{{ webSocket }}",argWebSocket).replace("{{ longPollServer }}",listen).replace("{{ leader }}",argsLeader).replace("{{ remoteDebug }}",argsDebug)})
var reTarget=RegExp("(http|https)://"+target+"/","g"),reTarget80=RegExp("(http|https)://"+target80+"/","g"),reTarget802=RegExp("(http|https)://"+target80+":80/","g"),reTarget1=RegExp("(http|https)://"+target,"g"),reTarget801=RegExp("(http|https)://"+target80,"g"),reTarget8021=RegExp("(http|https)://"+target80+":80","g"),sess=null,server=httpProxy.createServer(function(e,t){if(-1!==e.url.indexOf("/_mixture_update")){var r=url.parse(e.url,!0).query
lguid=r.guid,lurl=r.url,t.writeHead(200,{"Content-Type":"application/javascript","Cache-Control":"max-age=0"}),t.write("{ 'pollGuid': '"+lguid+"','pollUrl': '"+lurl+"' }"),t.end()}else if("/_mixture_longpoll"===e.url)t.writeHead(200,{"Content-Type":"application/javascript","Cache-Control":"max-age=0"}),t.write("{ 'pollGuid': '"+lguid+"','pollUrl': '"+lurl+"' }"),t.end()
else if("/_mixture_liverefresh"===e.url)t.writeHead(200,{"Content-Type":"application/javascript","Cache-Control":"max-age=0"}),t.write(liveRefreshScript.replace("{{ session }}",sess)),t.end()
else{var a=proxy(e,t,function(r){try{sess=get_cookies(a).MixDebugSession}catch(s){}(null==sess||void 0==sess)&&(sess="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(e){var t=0|16*Math.random(),r="x"==e?t:8|3&t
return r.toString(16)})),a.headers.host=target
var o={"Set-Cookie":"MixDebugSession="+sess},i=e.url;-1!==e.url.indexOf("?")&&(i=e.url.split("?")[0])
var n=RegExp(/\.[sS][vV][gG]$/),g=RegExp(/\.[jJ][sS]$/),c=RegExp(/\.[cC][sS][sS]$/)
if(i.match(g)?(o["Content-Type"]="application/javascript",t.writeHead(r.statusCode,o)):i.match(n)?(o["Content-Type"]="image/svg+xml",t.writeHead(r.statusCode,o)):i.match(c)&&(o["Content-Type"]="text/css; charset=utf-8",t.writeHead(r.statusCode,o)),/html/.test(r.headers["content-type"])?(o["Content-Type"]="text/html; charset=utf-8",t.writeHead(r.statusCode,o)):/javascript/.test(r.headers["content-type"])?(o["Content-Type"]="application/javascript",t.writeHead(r.statusCode,o)):/svg/.test(r.headers["content-type"])?(o["Content-Type"]="image/svg+xml",t.writeHead(r.statusCode,o)):/css/.test(r.headers["content-type"])&&(o["Content-Type"]="text/css; charset=utf-8",t.writeHead(r.statusCode,o)),301===r.statusCode||302===r.statusCode){var p=r.headers.location.replace(target,listen)
t.writeHead(r.statusCode,{Location:p,Expires:(new Date).toGMTString()}),t.end()}var l=""
r.on("data",function(e){if(t._hasBody)if(/html/.test(r.headers["content-type"])){var a=""+e
l+=a}else t.write(e,"binary")}),r.on("end",function(){if(l.length>0){null!=argTargetPort&&argTargetPort.length>0&&80!=argTargetPort?(l=l.replace(reTarget,"/"),l=l.replace(reTarget1,"/")):(l=l.replace(reTarget802,"/"),l=l.replace(reTarget80,"/"),l=l.replace(reTarget8021,"/"),l=l.replace(reTarget801,"/"))
var e=l.lastIndexOf("</html>");-1!=e&&argsDebug>0?l=[l.slice(0,e),"<script src='http://"+argListenHostname+":"+argsDebug+"/target/target-script-min.js#"+sess+"'></script>\n\r<script src='/_mixture_liverefresh'></script>",l.slice(e)].join(""):-1!=e&&(l=[l.slice(0,e),"<script src='/_mixture_liverefresh'></script>",l.slice(e)].join("")),t.write(l,encoding="utf8"),l=""}t.end()})})
e.pipe(a)}},argTargetPort,argTargetHostname,{changeOrigin:!0})
server.listen(argListenPort).on("error",function(e){console.log(e.message)})
var get_cookies=function(e){var t={}
return e.headers&&e.headers.cookie.split(";").forEach(function(e){var r=e.match(/(.*?)=(.*)$/)
t[r[1].trim()]=(r[2]||"").trim()}),t}