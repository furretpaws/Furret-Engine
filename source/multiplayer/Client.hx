package multiplayer;

import sys.net.Socket;
import haxe.io.Bytes;
import sys.net.Host;
import haxe.Timer;

class Client {
    public var socket:Socket;
    var timerLoop:Timer;
    var socketData:SomeBytes;
    public function new(ip:String, port:Int) {
        trace("1");
        socketData = new SomeBytes();
        trace("1");
        socket = new Socket();
        trace("1");
        try {
            socket.connect(new Host("127.0.0.1"), 80);
            trace("1");
        } catch (error:String) {
            onError(error);
            trace("1");
        }
        sys.thread.Thread.runWithEventLoop(()->{
            while(true) {
                trace("1");
                var input = socket.input;
                var out = new SomeBytes();
                try {
                    var data = Bytes.alloc(1024);
                    var readed = input.readBytes(data, 0, data.length);
                    if (readed <= 0) timerLoop.stop();
                    out.writeBytes(data.sub(0, readed));
                    var bytes:Bytes = out.readAllAvailableBytes();
                    socketData.writeBytes(bytes);
                    if (bytes.length != 0) {
                        var bytes:Bytes = socketData.readAllAvailableBytes();
                        onData(bytes);
                    }
                } catch (err:String) {
                    trace(err);
                    onError(err);
                }
            }
        });
    }

    public function sendData(d:haxe.io.Bytes) {
        trace("send!");
        socket.output.writeFullBytes(d, 0, d.length);
        trace("f=");
    }

    dynamic public function onData(d:haxe.io.Bytes) {

    }

    dynamic public function onError(d:String) {

    }
}