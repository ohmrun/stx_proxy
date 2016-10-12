import haxe.unit.TestRunner;


import stx.Proxy;

class Test{
  static function main(){
    var runner = new TestRunner();
        runner.add(new stx.ProxyTest());
        runner.run();
  }
}
