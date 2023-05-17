package multiplayer;

import sys.net.Socket;
import haxe.Timer;
import haxe.io.Bytes;

class SessionHandler {
    var server:Server;
    var sessions:Array<Session> = [];
    var users:Int = 0;
    var timer:Timer = null;
    var download_mode:Bool = true;
    var nextFileUpload:Bool = false;
    var voting_download_mode:Dynamic = null;
    var download_mode_votes:Int = 0;
    var ready_mode_votes:Int = 0;
    var match:Bool = false;
    public function new(sv:Server) {
        this.server = sv;
    }
    public function attachSession(session:Session) {
        this.sessions.push(session);
    }

    public function startHandling() {
        timer = new Timer(1);
        timer.run = () -> {
            users = sessions.length;
            for (i in 0...sessions.length) {
                try {
                    var out = new SomeBytes();
                    var input = sessions[i].socket.input;
                    var data = Bytes.alloc(1024);
	    		    var readed = input.readBytes(data, 0, data.length);
	    		    if (readed <= 0) break;
	    		    out.writeBytes(data.sub(0, readed));
                    var bytes:Bytes = out.readAllAvailableBytes();
	    	        if (bytes.length != 0) {
                        sessions[i].socketData.writeBytes(bytes);
                        handleBytes(sessions[i]);
                    }
                } catch (err) {
                    trace(err);
                    trace("An error has occurred in one of the clients. Probably the connection has been terminated. Removing his session...");
                    sessions.remove(sessions[i]);
                }
            }
        }
    }

    public function stopHandling() {
        if (this.timer != null) {
            this.timer.stop();
        }
    }

    private function handleBytes(session:Session) {
        var bytes:haxe.io.Bytes = session.socketData.readAllAvailableBytes();
        if (!nextFileUpload) {
            switch(session.state) {
                case "opened": //Awaiting a JSON request from him.
                    var json:Dynamic = null;
                    var continueLol:Bool = true;
                    try {
                        json = haxe.Json.parse(bytes.toString());
                        trace(json);
                    } catch (err) {
                        var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                            failed: true,
                            action: "DECLINE_REQUEST",
                            d: {
                                reason: "You have given us an invalid JSON response. Expected a JSON request on the opening state."
                            }
                        }));
                        session.send(bytes);
                        session.socket.close();
                        sessions.remove(session);
                        server.onPrivateEvents(bytes.toString(), session);
                        continueLol = false;
                    }
                    if (continueLol) {
                        switch (json.action) {
                            case "GET_INFO":
                                var users:Array<String> = [];
                                for (i in 0...sessions.length) {
                                    if (sessions[i].username != null || sessions[i].username != "") {
                                        users.push(sessions[i].username);
                                    }
                                }
                                var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                    failed: false,
                                    action: "GIVE_INFO",
                                    d: {
                                        users: users.length,
                                        users_list: users,
                                        onAMatch: this.match
                                    }
                                }));
                                session.send(bytes);
                                session.socket.close();
                                server.onPrivateEvents(bytes.toString(), session);
                                sessions.remove(session);
                            case "JOIN":
                                var canJoin:Bool = true;
                                for (i in 0...sessions.length) {
                                    if (sessions[i].username != null) {
                                        if (sessions[i].username.toLowerCase() == json.d.username) {
                                            var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                                failed: true,
                                                action: "DECLINE_REQUEST",
                                                d: {
                                                    reason: 'The username "' + sessions[i].username + '" is already taken'
                                                }
                                            }));
                                            session.send(bytes);
                                            session.socket.close();
                                            server.onPrivateEvents(bytes.toString(), session);
                                            sessions.remove(session);
                                            continueLol = false;
                                        }
                                    }
                                }
                                if (json.d.furretEngineVer == null) {
                                    var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                        failed: true,
                                        action: "DECLINE_REQUEST",
                                        d: {
                                            reason: "You are lacking the Furret Engine version parameter! (furretEngineVer)"
                                        }
                                    }));
                                    session.send(bytes);
                                    session.socket.close();
                                    server.onPrivateEvents(bytes.toString(), session);
                                    sessions.remove(session);
                                    continueLol = false;
                                }
                                if (canJoin && continueLol) {
                                    session.changeUsername(json.d.username);
                                    session.changeHost(session.socket.host().host.host+":"+session.socket.host().port);
                                    trace(session.username);
                                    var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                        failed: true,
                                        action: "ACCEPTED_JOIN_REQUEST",
                                        d: {
                                            username: json.username
                                        }
                                    }));
                                    session.state = "connected";
                                    session.send(bytes);
                                    server.onPrivateEvents(bytes.toString(), session);
                                    var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                        action: "PLAYER_JOINED",
                                        d: {
                                            user: session.username
                                        }
                                    }));
                                    server.onEvent(bytes.toString());
                                    sendGlobalMessage(bytes);
                                    var users:Array<String> = [];
                                    for (i in 0...sessions.length) {
                                        if (sessions[i].username != null || sessions[i].username != "") {
                                            users.push(sessions[i].username);
                                        }
                                    }
                                    var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                        action: "PLAYER_COUNT_CHANGED",
                                        d: {
                                            count: users.length
                                        }
                                    }));
                                    server.onEvent(bytes.toString());
                                    sendGlobalMessage(bytes);
                                }
                        }
                    }
                case "connected":
                    var json:Dynamic = null;
                    var continueLol:Bool = true;
                    try {
                        json = haxe.Json.parse(bytes.toString());
                        trace(json);
                    } catch (err) {
                        var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                            failed: true,
                            action: "DECLINE_REQUEST",
                            d: {
                                reason: "You have given us an invalid JSON response. Expected a JSON request."
                            }
                        }));
                        session.send(bytes);
                        session.socket.close();
                        sessions.remove(session);
                        continueLol = false;
                    }
                    if (continueLol) {
                        switch(json.action) {
                            case "TAKE_OWNERSHIP":
                                if (json.d.key == server.key) {
                                    session.ownership = true;
                                }
                                var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                    failed: false,
                                    action: "OWNERSHIP_GRANTED",
                                    d: null
                                }));
                                server.onPrivateEvents(bytes.toString(), session);
                                session.send(bytes);
                            case "REQUEST_DOWNLOAD_MODE":
                                voting_download_mode = {
                                    filename: json.d.filename, 
                                };
                                var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                    action: "USER_REQUESTED_DOWNLOAD_MODE",
                                    d: {
                                        user: session.username,
                                        filename: voting_download_mode.filename,
                                        time: 30
                                    }
                                }));
                                sendGlobalMessage(bytes);
                            case "UPLOAD_FILE": 
                                var bytes:Bytes = Bytes.ofString(haxe.Json.stringify({
                                    action: "UPLOAD_FILE",
                                    d: {
                                        filename: "images/imageuwu.png",
                                        user: json.d.user
                                    }
                                }));
                                sendGlobalMessage(bytes);
                                nextFileUpload = true;
                        }
                    }
            }
        } else {
            nextFileUpload = false;
        }
    }

    private function sendGlobalMessage(bytes:haxe.io.Bytes) {
        for (i in 0...sessions.length) {
            if (sessions[i].state == "connected") {
                sessions[i].send(bytes);
            }
        }
        server.onEvent(haxe.Json.stringify(bytes));
    }
}