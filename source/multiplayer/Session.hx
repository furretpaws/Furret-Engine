package multiplayer;

import sys.net.Socket;
import haxe.io.BytesOutput;

class Session {
    public var socket:Socket = null;
    public var state:String = "opened";
    public var socketData:BytesOutput = null;
    public var username:String = null;
    public var host:String = null;
    public var ready:Bool = false;
    public var ownership:Bool = false;
    public var download_mode_vote:Int = 0;
    public var arrow_pressed:Array<Bool> = [false, false, false, false];
    public var arrow_just_pressed:Array<Bool> = [false, false, false, false];
    public var arrow_just_unhold:Array<Bool> = [false, false, false, false];
    public function new (socket:Socket) {
        this.socket = socket;
        this.socketData = new BytesOutput();
    }
    public function changeUsername(username:String) {
        this.username = username;
    }
    public function changeHost(IP:String) {
        this.host = IP;
    }
    public function changeReadyState(ready:Bool) {
        this.ready = ready;
    }
    public function changeKeyPressed(index:Int, press:Bool) {
        arrow_pressed[index] = press;
    }
    public function changeKeyPress(index:Int, press:Bool) {
        arrow_just_pressed[index] = press;
    }
    public function changeKeyUnpressed(index:Int, press:Bool) {
        arrow_just_unhold[index] = press;
    }
    public function send(bytes:haxe.io.Bytes) {
        this.socket.output.writeFullBytes(bytes, 0, bytes.length);
    }
}