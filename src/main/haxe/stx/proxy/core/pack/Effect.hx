package stx.proxy.core.pack;

typedef EffectDef<R,E>     = ProxySum<Closed,Noise,Noise,Closed,R,E>;

abstract Effect<R,E>(EffectDef<R,E>) from EffectDef<R,E> to EffectDef<R,E>{
  public function new(self) this = self;
  static public function lift(self:EffectDef<R,E>) return new Effect(self);
  
  public function flat_map<O>(fn:Arrowlet<R,Effect<O,E>>):Effect<O,E>{
    return lift(
      Proxy._.flat_map(
        this,
        fn.then((x:Effect<O,E>)->x.prj())
      )
    );
  }
  public function prj():EffectDef<R,E>{
    return this;
  }
}