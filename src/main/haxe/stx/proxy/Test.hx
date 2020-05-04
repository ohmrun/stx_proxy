package stx.proxy;

import stx.proxy.test.*;

class Test{
  static public function tests():Array<utest.Test>{
    return [
      new ProxyTest()
    ];
  }
}