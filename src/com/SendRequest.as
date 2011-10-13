package com 
{
	import flash.events.SecurityErrorEvent;	
	import flash.events.IOErrorEvent;	
	import flash.events.Event;	
	import flash.events.HTTPStatusEvent;	
	import flash.net.URLLoaderDataFormat;	
	import flash.net.URLRequestHeader;	
	import flash.net.URLVariables;	
	import flash.net.URLLoader;	
	import flash.net.URLRequest;	
	
	/**
	 * @author Tiger
	 */
	public class SendRequest 
	{
		private var loader : URLLoader = null;
		private var httpStatus : int = 0;
		private var httpStatusText : String = "";
		
		public function SendRequest()
		{
			loader = new URLLoader();
			addLoaderListeners();
		}
		
		public function Send(method : String, url : String, header : String = null, post : String = null) : void
		{
			MainPost.Log("SendRequest.Send");
			MainPost.Log("method = " + method);
			MainPost.Log("url = " + url);
			MainPost.Log("header = " + header);
			MainPost.Log("post = " + post);
			
			var qq : int;
			var tmp : Array;
			var hinfo : Array;

			var urlRequest : URLRequest = new URLRequest();
			urlRequest.url = url;
			urlRequest.method = method;
			if(post)
			{
				var vvv : URLVariables = new URLVariables();
				tmp = post.split("&");
				for(qq = 0; qq < tmp.length; qq++)
				{
					hinfo = String(tmp[qq]).split("=",2);
					if(String(hinfo[0]).length > 0)
						vvv[hinfo[0]] = hinfo[1];
				}
				urlRequest.data = vvv;
			}
			if(header)
			{
				tmp = header.split("&");
				for(qq = 0; qq < tmp.length; qq++)
				{
					hinfo = String(tmp[qq]).split(":",2);
					urlRequest.requestHeaders.push(new URLRequestHeader(hinfo[0]?hinfo[0]:"", hinfo[1]?hinfo[1]:""));
				}
			}
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(urlRequest);
		}
		
		private function addLoaderListeners() : void
		{
			loader.addEventListener(Event.COMPLETE, onLoadComlete);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusChange);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
//		private function removeLoaderListeners() : void
//		{
//			loader.removeEventListener(Event.COMPLETE, onLoadComlete);
//			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusChange);
//			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
//			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
//		}
		
		private function onHttpStatusChange(event : HTTPStatusEvent) : void
		{
			MainPost.Log("SendRequest.onHttpStatusChange : " + event.status.toString());
			httpStatus = int(event.status);
			if (event.status != 0 && event.status < 400) return;
			
			var msg:String;
			switch(event.status)
			{
				case 400:
					msg = "Bad Request";
					break;
				case 401:
					msg = "Unauthorized";
					break;
				case 403:
					msg = "Forbidden";
					break;
				case 404:
					msg = "Not Found";
					break;
				case 405:
					msg = "Method Not Allowed";
					break;
				case 406:
					msg = "Not Acceptable";
					break;
				case 407:
					msg = "Proxy Authentication Required";
					break;
				case 408:
					msg = "Request Timeout";
					break;
				case 409:
					msg = "Conflict";
					break;
				case 410:
					msg = "Gone";
					break;
				case 411:
					msg = "Length Required";
					break;
				case 412:
					msg = "Precondition Failed";
					break;
				case 413:
					msg = "Request Entity Too Large";
					break;
				case 414:
					msg = "Request-URI Too Long";
					break;
				case 415:
					msg = "Unsupported Media Type";
					break;
				case 416:
					msg = "Requested Range Not Satisfiable";
					break;
				case 417:
					msg = "Expectation Failed";
					break;
				case 500:
					msg = "Internal Server Error";
					break;
				case 501:
					msg = "Not Implemented";
					break;
				case 502:
					msg = "Bad Gateway";
					break;
				case 503:
					msg = "Service Unavailable";
					break;
				case 504:
					msg = "Gateway Timeout";
					break;
				case 505:
					msg = "HTTP Version Not Supported";
					break;
				default:
					msg = "Unhandled HTTP status";
			}
			httpStatusText = msg;
		}
		
		private function onLoadComlete(event : Event) : void
		{
			MainPost.Log("SendRequest.onLoadComlete");
			var data : String = URLLoader(event.target).data as String;
			MainPost.Log(data);
			MainPost.CallJSFunction(MainPost.successFunc, httpStatus.toString(), data);
		}
		
		private function onIOError(e : IOErrorEvent) : void
		{
			MainPost.Log("SendRequest.onIOError");
			MainPost.CallJSFunction(MainPost.errorFunc, String(httpStatus));
		}
		
		private function onSecurityError(e : IOErrorEvent) : void
		{
			MainPost.Log("SendRequest.onSecurityError");
			MainPost.CallJSFunction(MainPost.errorFunc, String(httpStatus));
		}
	}
}
