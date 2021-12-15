package stx.proxy;

class Lift{
  static public function proxy(__:Wildcard){
    return new Api();
  }
}
class Api{
  public function new(){}
  // public function lift<A,B,X,Y,R,E>(prx:stx.proxy.core.head.data.Proxy<A,B,X,Y,R,E>):stx.proxy.core.Proxy<A,B,X,Y,R,E>{
  //   return stx.proxy.core.Proxy.lift(prx);
  // }
}
