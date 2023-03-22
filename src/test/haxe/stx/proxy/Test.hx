package stx.proxy;

using stx.Test;

import stx.proxy.test.*;

class Test{
  static public function tests():Array<TestCase>{
    return [
      new ProxyTest()
    ];
  }
}