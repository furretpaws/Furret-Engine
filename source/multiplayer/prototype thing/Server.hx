package multiplayer;

import sys.net.Socket;
import sys.net.Host;

class Server {
    public var socket:Socket = null;
    public var ip:String = null;
    public var port:Int = 0;
    public var players:Int = 0;
    public var sessionHandler:SessionHandler = null;
    public function new(ip:String, port:Int) {
        this.ip = ip;
        this.port = port;
        this.socket = new Socket();
        this.sessionHandler = new SessionHandler(this);
        sys.thread.Thread.create((continueSocket));
    }

    function continueSocket() {
        trace("?");
        try {
            socket.bind(new Host(ip), port);
        } catch (err:String) {
            onError("Couldn't bind to " + ip + ":" + port);
        }
        socket.listen(32);
        haxe.EntryPoint.runInMainThread(this.sessionHandler.startHandling);
        while(true) {
            try {
                var clientSocket:Socket = socket.accept();
                var session:Session = new Session(clientSocket);
                this.sessionHandler.attachSession(session);
            } catch (err) {
                trace(err);
            }
        }
    }

    dynamic public function onPrivateRequests(d:String, session:Session) {

    }

    dynamic public function onEvent(d:String) {

    }
    
    dynamic public function onError(d:String) {

    }
}