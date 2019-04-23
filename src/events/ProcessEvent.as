package events {
    import flash.events.Event;

    public class ProcessEvent extends Event 
	{
        public static const END:String = "end";
		public var data:Object;
        public function ProcessEvent(type:String){
            super(type);
        }
    }
}