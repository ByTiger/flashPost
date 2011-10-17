package com 
{
	import flash.events.ProgressEvent;	
	import flash.events.DataEvent;	
	import flash.net.URLRequestMethod;	
	import flash.events.SecurityErrorEvent;	
	import flash.events.IOErrorEvent;	
	import flash.events.HTTPStatusEvent;	
	import flash.events.Event;	
	import flash.net.URLRequestHeader;	
	import flash.net.URLVariables;	
	import flash.net.URLRequest;	
	import flash.net.FileReference;	
	
	/**
	 * @author Tiger
	 */
	public class PostFile
	{
		private var urlRequest : URLRequest = null;
		private var loader : FileReference = null;
		private var httpStatus : int = 0;
		private var httpStatusText : String = "";
		private var isFileSelected : Boolean = false;
		
		public function PostFile()
		{
			if(!loader)
			{
				loader = new FileReference();
				addLoaderListeners();
			}
		}
		
		public function SelectFile() : void
		{
			loader.browse();
		}
		
		private function OnFileSelect(e : Event) : void
		{
//			trace("OnFileSelect");
			var nn : String = FileReference(e.currentTarget).name;
			var ss : int = FileReference(e.currentTarget).size;
			isFileSelected = true;
			MainPost.CallJSFunction(MainPost.userSelectFile, nn, ss.toString());
		}
		
		private function OnFileSelectCancel(e : Event) : void
		{
//			trace("OnFileSelectCancel");
			MainPost.CallJSFunction(MainPost.userCancel);
		}
		
		public function Post(url : String, fileField : String, header : String = null, post : String = null) : void
		{
			if(!isFileSelected)
			{
				MainPost.CallJSFunction(MainPost.fileNotSelected);
				return;
			}
			
			var qq : int;
			var tmp : Array;
			var hinfo : Array;
			
			urlRequest = new URLRequest();
			urlRequest.url = url;
			urlRequest.method = URLRequestMethod.POST;
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
			urlRequest.contentType = "multipart/form-data";
			loader.upload(urlRequest, fileField);
		}
		
		private function addLoaderListeners() : void
		{
			loader.addEventListener(Event.SELECT, OnFileSelect);
			loader.addEventListener(Event.CANCEL, OnFileSelectCancel);

            loader.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusChange);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            loader.addEventListener(Event.OPEN, onSendStart);
            loader.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            loader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadDataComplete);
		}
		
//		private function removeLoaderListeners() : void
//		{
//			loader.removeEventListener(Event.SELECT, OnFileSelect);
//			loader.removeEventListener(Event.CANCEL, OnFileSelectCancel);
//            loader.removeEventListener(Event.COMPLETE, onLoadComplete);
//            loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusChange);
//            loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
//            loader.removeEventListener(Event.OPEN, onSendStart);
//            loader.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
//            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
//            loader.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadDataComplete);
//		}
		
		private function onUploadProgress(e : ProgressEvent) : void
		{
//			trace("onUploadProgress", e.bytesLoaded.toString(), e.bytesTotal.toString());
			MainPost.CallJSFunction(MainPost.fileProgress, e.bytesLoaded.toString(), e.bytesTotal.toString());
		}
		
		private function onUploadDataComplete(e : DataEvent) : void
		{
//			trace("onUploadDataComplete");
			var data : String = e.data as String;
			if(data==null) data = "";
			MainPost.CallJSFunction(MainPost.successFunc, httpStatus.toString(), data);
		}
		
		private function onSendStart(e : Event) : void
		{
//			trace("onSendStart");
			MainPost.CallJSFunction(MainPost.startFilePost, FileReference(e.currentTarget).name);
		}
		
		private function onHttpStatusChange(event : HTTPStatusEvent) : void
		{
//			trace("onHttpStatusChange: " + event.status);
			httpStatus = int(event.status);
			if(event.status != 0 && event.status < 400) return;
			
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
		
		private function onLoadComplete(event : Event) : void
		{
//			trace("onLoadComplete");
		}
		
		private function onIOError(e : IOErrorEvent) : void
		{
//			trace("onIOError");
			MainPost.CallJSFunction(MainPost.errorFunc, String(httpStatus));
		}
		
		private function onSecurityError(e : IOErrorEvent) : void
		{
//			trace("onSecurityError");
			MainPost.CallJSFunction(MainPost.errorFunc, String(httpStatus));
		}
	}
}
