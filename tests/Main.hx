package ;

import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw = quot;
        trace(raw.encode(false), raw.encode(true));
    }

}