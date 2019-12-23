package stx.proxy.core.pack;

@:forward abstract Yielder<A,B,X,Y,R,E>(Proxy<A,B,X,Y,R,E>) from Proxy<A,B,X,Y,R,E> to Proxy<A,B,X,Y,R,E>{
  public function new(proxy){
    this = proxy;
  }
  /*
  public function map<Y1>(fn:Y->Y1):Yield<A,B,X,Y1,R,E>{
    return Yields.map(this,fn);
  }
  public function tap(fn:Y->Void):Yield<A,B,X,Y,R,E>{
    return Yields.tap(this,fn);
  }
  public function then<Y1>(fn:Arrowlet<Y,Y1>):Yield<A,B,X,Y1,R,E>{
    return Yields.then(this,fn);
  }*/
  public function prj():Proxy<A,B,X,Y,R,E>{
    return this;
  }
}