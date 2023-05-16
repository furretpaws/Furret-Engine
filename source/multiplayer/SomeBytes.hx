package multiplayer;

import haxe.io.Bytes;

class SomeBytes {
    public var available(default, null):Int = 0;
    private var currentOffset:Int = 0;
    private var currentData: Bytes = null;
    private var chunks:Array<Bytes> = [];

    public function new() {

    }

    public function writeBytes(data:Bytes) {
        chunks.push(data);
        available += data.length;
    }

    public function readAllAvailableBytes():Bytes {
        return readBytes(available);
    }

    public function readBytes(count:Int):Bytes {
        var count2 = Std.int(Math.min(count, available));
        var out = Bytes.alloc(count2);
        for (n in 0 ... count2) out.set(n, readByte());
        return out;
    }

    public function readByte():Int {
        if (available <= 0) throw 'Not bytes available';
        while (currentData == null || currentOffset >= currentData.length) {
            currentOffset = 0;
            currentData = chunks.shift();
        }
        available--;
        return currentData.get(currentOffset++);
    }
}