package stx.proxy.core;

typedef OutletDef<R,E>     = ProxySum<Closed,Noise,Noise,Closed,R,E>;

abstract Outlet<R,E>(OutletDef<R,E>) from OutletDef<R,E> to OutletDef<R,E>{
  public function new(self) this = self;
  static public function lift<R,E>(self:OutletDef<R,E>) return new Outlet(self);
  
  public function flat_map<O>(fn:Unary<R,Outlet<O,E>>):Outlet<O,E>{
    return lift(
      Proxy._.flat_map(
        this,
        fn.then((x:Outlet<O,E>)->x.prj())
      )
    );
  }
  public function prj():OutletDef<R,E>{
    return this;
  }
}