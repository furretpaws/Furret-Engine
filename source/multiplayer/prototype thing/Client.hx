import sys.net.Socket;
import sys.net.Host;
import haxe.io.Bytes;

class Client {
    static var socket:Socket;
    static function main() {
        socket = new Socket();
        socket.connect(new Host("127.0.0.1"), 80);
        var req:Bytes = Bytes.ofString(haxe.Json.stringify({
            action: "GET_INFO"
        }));
        socket.output.writeFullBytes(req, 0, req.length);
        while (true) {
            try {
                var byteBuffer = Bytes.alloc(1024);
                var output:String;
                var bytesRead:Int = socket.input.readBytes(byteBuffer, 0, 1024);
                var byteString = Bytes.alloc(bytesRead);
                byteString.blit(0, byteBuffer, 0, bytesRead);
                output = byteString.toString();
                
                trace(output);
            }
        }
    }
}