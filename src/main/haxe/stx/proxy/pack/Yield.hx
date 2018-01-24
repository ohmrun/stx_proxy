package stx.proxy.pack;

@:forward abstract Yield<A,B,X,Y,R>(Proxy<A,B,X,Y,R>) from Proxy<A,B,X,Y,R> to Proxy<A,B,X,Y,R>{
  public function new(proxy){
    this = proxy;
  }
  public function map<Y1>(fn:Y->Y1):Yield<A,B,X,Y1,R>{
    return Yields.map(this,fn);
  }
  public function tap(fn:Y->Void):Yield<A,B,X,Y,R>{
    return Yields.tap(this,fn);
  }
  public function then<Y1>(fn:Arrowlet<Y,Y1>):Yield<A,B,X,Y1,R>{
    return Yields.then(this,fn);
  }
  public function asProxy():Proxy<A,B,X,Y,R>{
    return this;
  }
}