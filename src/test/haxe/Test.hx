import haxe.unit.TestRunner;


import stx.Proxy;

class Test{
  static function main(){
    var runner = new TestRunner();
        runner.add(new stx.ProxyTest());
        runner.add(new ProcessTest());
        runner.run();
  }
}
class ProcessTest extends haxe.unit.TestCase{
  public function test(){}
}
class Process{
  public function new(cmd:String,args:Array<String>){
    var proc = new sys.io.Process(cmd,args);
        proc.
  }
}
