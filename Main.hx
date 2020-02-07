
class Main{
  static function main(){
    #if test
      utest.UTest.run(
        stx.proxy.core.Package.tests().concat(
          stx.proxy.io.Package.tests()
        )
      );
    #end
  }
}