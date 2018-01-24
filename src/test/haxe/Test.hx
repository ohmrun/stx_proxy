import haxe.unit.TestRunner;

using stx.proxy.Package;

class Test{
  static function main(){
    var runner = new TestRunner();
        runner.add(new stx.proxy.ProxyTest());
        runner.add(new ProcessTest());
        runner.run();
  }
}
class ProcessTest extends haxe.unit.TestCase{
  public function test(){}
}
class Process{
  public function new(cmd:String,args:Array<String>){
    
  }
}
