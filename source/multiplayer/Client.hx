package multiplayer;

import sys.net.Socket;
import haxe.io.Bytes;
import sys.net.Host;

class Client {
    public var socket:Socket;
    var socketData:SomeBytes;
    public function new(ip:String, port:Int) {
        socketData = new SomeBytes();
        socket = new Socket();
        try {
            socket.connect(new Host("127.0.0.1"), 80);
        } catch (error:String) {
            onError(error);
        }
        while (true) {
            var input = socket.input;
            var out = new SomeBytes();
            try {
                var data = Bytes.alloc(1024);
                var readed = input.readBytes(data, 0, data.length);
                if (readed <= 0) break;
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
    }

    public function sendData(d:haxe.io.Bytes) {
        socket.output.writeFullBytes(d, 0, d.length);
        socket.output.flush();
    }

    dynamic public function onData(d:haxe.io.Bytes) {

    }

    dynamic public function onError(d:String) {

    }
}