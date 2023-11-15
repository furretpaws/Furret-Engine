class Principal {
    static function main() {
        var myClient:Client = new Client("fffff ff", 80);
        myClient.sendData(haxe.io.Bytes.ofString("fuck you"));
    }
}