package multiplayer;

import sys.net.Socket;
import sys.net.Host;

class Server {
    public var socket:Socket = null;
    public var ip:String = null;
    public var port:Int = 0;
    public var players:Int = 0;
    public var sessionHandler:SessionHandler = null;
    public var key:String = "";
    public function new(ip:String, port:Int, ownershipKey:String) {
        this.ip = ip;
        this.port = port;
        this.socket = new Socket();
        this.sessionHandler = new SessionHandler(this);
        this.key = ownershipKey;
        haxe.EntryPoint.addThread(continueSocket);
    }

    function continueSocket() {
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

    dynamic public function onEvent(d:String) {

    }
    
    dynamic public function onError(d:String) {

    }
}