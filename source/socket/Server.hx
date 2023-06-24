package socket;

import sys.net.Socket;
import sys.net.Host;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Error;

class Server {
    var socket:Socket;
    var bytesOutput:BytesOutput;
    var sockets:Array<Socket> = [];
    var ip:String = "";
    var port:Int = 0;
    public function new(ip:String, port:Int) {
        this.ip = ip;
        this.port = port;
    }
    public function start() {
        bytesOutput = new BytesOutput();
        socket = new Socket();
        socket.setBlocking(false);
        socket.bind(new Host(ip), port);
        socket.listen(8196);
        onStarted();
        while(true) {
            var assignFailed:Bool = false;
            var client:Socket = null;
            try {
                client = socket.accept();
            } catch (error:String) {
                if (error.toLowerCase() == "blocking") {
                    //no blocking sir
                } else {
                    //trace(error);
                    assignFailed = true;
                }
            }
            if (!assignFailed && !sockets.contains(client)) {
                if (client != null) {
                    onClientConnect(client);
                    sockets.push(client);
                }
            }

            for (i in 0...sockets.length) {
                handleBytes(sockets[i]);
            }
        }
    }
    function handleBytes(socket:Socket) {
        var bytes:Bytes = Bytes.alloc(1024);
        var failed:Bool = false;
        var read:Int = 0;
        try {
            read = socket.input.readBytes(bytes, 0, bytes.length);
        } catch (err:Dynamic) {
            //Here we should consider Blocking as an critical error, meaning there is no data in the socket
            failed = true;
            if (err != Error.Blocked) {
                sockets.remove(socket);
                onClientDisconnect(socket);
            } else if (Std.string(err).toLowerCase() == "eof") {
                sockets.remove(socket);
                onClientDisconnect(socket);
            }
        }
        if (!failed) {
            if (read == 1024) {
                //maybe more data idk, let's write and check again
                bytesOutput.writeBytes(bytes, 0, bytes.length);
                handleBytes(socket);
            } else if (read < 1024 && read > 0) {
                //last chunk of data probably
                bytesOutput.writeBytes(bytes, 0, bytes.length);
            } else if (read == 0) {
                //end!
            }
            var ib:IncomingBytes = new IncomingBytes(socket, bytesOutput.getBytes());
            onData(ib);
            bytesOutput = new BytesOutput();
        }
    }
    public dynamic function onData(ib:IncomingBytes) {
        
    }
    public dynamic function onClientDisconnect(socket:Socket) { }
    public dynamic function onStarted() { }
    public dynamic function onClientConnect(socket:Socket) { }
}

class IncomingBytes {
    public var socket:Socket;
    public var bytes:Bytes;
    public function new(socket:Socket, bytes:Bytes) {
        this.socket = socket;
        this.bytes = bytes;
    }

    public function send(hb:Bytes) {
        //trace(hb);
        try {
            socket.output.writeBytes(hb, 0, hb.length);
            socket.output.flush();
        } catch (err) {
            trace(err);
        }
    }

    public function disconnect() {
        socket.close();
    }
}