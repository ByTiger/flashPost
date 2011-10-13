package  
{
	import flash.events.MouseEvent;	
	import flash.system.Security;	
	import flash.external.ExternalInterface;	
	
	import com.PostFile;
	import com.SendRequest;
	
	import flash.display.Sprite;
	
	[SWF (width="100", height="100", frameRate="16", backgrouondColor="#ffffff")]
	
	/**
	 * @author Tiger
	 */
	public class MainPost extends Sprite
	{
		static public var successFunc : String = "netGateSuccess";
		static public var errorFunc : String = "netGateError";
		static public var userCancel : String = "netGateUserCancel";
		static public var userSelectFile: String = "netGateUserSelectFile";
		static public var startFilePost: String = "netGateStartFilePost";
		static public var fileProgress: String = "netGateProgress";
		static public var debugFunc: String = "netGateDebug";
		static public var fileNotSelected: String = "netGateFileNotSelected";
		
		private var sendReq : SendRequest = null;
		private var postReq : PostFile = null;
		static public var id : String = "";

		
		public function MainPost()
		{
			if(this.loaderInfo.parameters["id"])
				MainPost.id = this.loaderInfo.parameters["id"];
			
			sendReq = new SendRequest();
			postReq = new PostFile();

			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(0, 0, 100, 100);
			this.graphics.endFill();
			
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void{
				postReq.SelectFile();
			});

			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			if(!ExternalInterface.available) return;
			ExternalInterface.addCallback("netGateSendRequest", netGateSendRequest);
		}
		
		private function netGateSendRequest(method : String, url : String, post : String = null, header : String = null, fileField : String = "filedata") : void
		{
			if(method.toLowerCase() == "file")
			{
				postReq.Post(url,fileField,(header!=null && header.length>0)?header:"",(post!=null && post.length>0)?post:"");
			}
			else
				sendReq.Send(method,url,(header!=null && header.length>0)?header:"",(post!=null && post.length>0)?post:"");
		}
		
		static public function Log(str : String) : void
		{
			MainPost.CallJSFunction(debugFunc, str);
		}
		
		// call JS function
		static public function CallJSFunction(func : String, prm1 : String = null, prm2 : String = null, prm3 : String = null) : String
		{
			if(!ExternalInterface.available)
			{
				return "";
			}
			
			var res : String ="";
			if(prm3 != null)
			{
				res = String(ExternalInterface.call(func, MainPost.id, prm1, prm2, prm3));
			}
			else if(prm2 != null)
			{
				res = String(ExternalInterface.call(func, MainPost.id, prm1, prm2));
			}
			else if(prm1 != null)
			{
				res = String(ExternalInterface.call(func, MainPost.id, prm1));
			}
			else
			{
				res = String(ExternalInterface.call(func, MainPost.id));
			}
			return res;
		}
	}
}
