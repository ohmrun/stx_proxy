package stx.proxy.core.pack;

typedef BelayDef<A,B,X,Y,R,E> = Void -> Future<Proxy<A,B,X,Y,R,E>>;

abstract Belay<A,B,X,Y,R,E>(BelayDef<A,B,X,Y,R,E>) from BelayDef<A,B,X,Y,R,E> to BelayDef<A,B,X,Y,R,E>{
  public function new(self) this = self;
  static public function lift<A,B,X,Y,R,E>(self:BelayDef<A,B,X,Y,R,E>):Belay<A,B,X,Y,R,E> return new Belay(self);
  
  @:from static public function fromThunk<A,B,X,Y,R,E>(fn:Thunk<Proxy<A,B,X,Y,R,E>>):Belay<A,B,X,Y,R,E>{
    return lazy(fn);
  }
  @:noUsing static public function lazy<A,B,X,Y,R,E>(fn:Thunk<Proxy<A,B,X,Y,R,E>>):Belay<A,B,X,Y,R,E>{
    return () -> Future.async(
      (cb) -> cb(fn())
    );
  }
  

  public function prj():BelayDef<A,B,X,Y,R,E> return this;
  private var self(get,never):Belay<A,B,X,Y,R,E>;
  private function get_self():Belay<A,B,X,Y,R,E> return lift(this);

  public function mod<Ai,Bi,Xi,Yi,Ri>(fn:Proxy<A,B,X,Y,R,E>->Proxy<Ai,Bi,Xi,Yi,Ri,E>):Belay<Ai,Bi,Xi,Yi,Ri,E>{
    return () -> this().map(fn);
  }
  @:to public function toProxy():Proxy<A,B,X,Y,R,E>{
    return Defer(this);
  }
}