package socket;

import sys.net.Socket;
import sys.net.Host;
import haxe.io.Bytes;
import haxe.io.Error;
import haxe.Timer;
import haxe.io.BytesOutput;

class Client {
    var socket:Socket;
    var ip:String;
    var port:Int = 0;
    var timer:Timer;
    var lastRead:Int = 0;
    var socketData:BytesOutput;
    var somethingGoingOn:Bool = false;
    public function new(ip:String, port:Int) {
        this.ip = ip;
        this.port = port;
    }
    public function connect() {
        socketData = new BytesOutput();
        socket = new Socket();
        socket.setBlocking(false);
        socket.connect(new Host(ip), port);
        timer = new Timer(1);
        timer.run = () -> {
            var read:Int = 0;
            var bytes:Bytes = Bytes.alloc(1024);
            var doNotContinue:Bool = false;
            try {
                read = socket.input.readBytes(bytes, 0, bytes.length);
            } catch (err) {
                if (err.toString() == "Blocked") {
                    //do nothing
                    doNotContinue = true;   
                } else {
                    doNotContinue = true;
                    onDisconnect();
                    timer.stop();
                }
            }
            if (!doNotContinue) {
                lastRead = read;
                if (read > 0) {
                    socketData.writeBytes(bytes, 0, read);
                    if (read == 1024) {
                        handleBytes(socket);
                    }
                    onData(socketData.getBytes());
                }
                socketData = new BytesOutput();
            }
        }
    }

    function handleBytes(socket:Socket) {
        var bytes = Bytes.alloc(1024);
        var failed:Bool = false;
        var read:Int = 0;
        try {
            read = socket.input.readBytes(bytes, 0, bytes.length);
        } catch (err) {
            failed = true;
        }
        if (!failed) {
            if (read == 1024) { //there might be more data
                socketData.writeBytes(bytes, 0, read);
                handleBytes(socket);
            } else if (read != 1024 && read > 0) {
                //last straw i think
                socketData.writeBytes(bytes, 0, read);
            } else if (read == 0) {
                //nothing
            }
        }
    }

    public function send(bytes:Bytes) {
        socket.output.writeBytes(bytes, 0, bytes.length);
    }

    public dynamic function onData(bytes:Bytes) {
        
    }

    public dynamic function onDisconnect() {

    }
}