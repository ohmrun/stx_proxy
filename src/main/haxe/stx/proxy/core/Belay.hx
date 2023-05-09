package stx.proxy.core;

/**
 * @see 
 */
typedef BelayDef<A,B,X,Y,R,E> = ProvideDef<Proxy<A,B,X,Y,R,E>>;

abstract Belay<A,B,X,Y,R,E>(BelayDef<A,B,X,Y,R,E>) from BelayDef<A,B,X,Y,R,E> to BelayDef<A,B,X,Y,R,E>{
  public function new(self) this = self;
  @:noUsing static public function lift<A,B,X,Y,R,E>(self:BelayDef<A,B,X,Y,R,E>):Belay<A,B,X,Y,R,E> return new Belay(self);
  
  @:from static public function fromFunXR<A,B,X,Y,R,E>(fn:Void -> Proxy<A,B,X,Y,R,E>):Belay<A,B,X,Y,R,E>{
    return lazy(fn);
  }
  @:from static public function fromThunk<A,B,X,Y,R,E>(fn:Thunk<Proxy<A,B,X,Y,R,E>>):Belay<A,B,X,Y,R,E>{
    return lazy(fn);
  }
  @:from static public function fromFuture<A,B,X,Y,R,E>(fn:Thunk<Future<Proxy<A,B,X,Y,R,E>>>):Belay<A,B,X,Y,R,E>{
    return lift(Provide.fromFunXFuture(
      () -> {
        return fn();
      }
    ));
  }
  @:noUsing static public function lazy<A,B,X,Y,R,E>(fn:Thunk<Proxy<A,B,X,Y,R,E>>):Belay<A,B,X,Y,R,E>{
    return lift(Provide.fromFunXFuture(() -> Future.irreversible(
      (cb) -> cb(fn())
    )));
  }
  

  public function prj():BelayDef<A,B,X,Y,R,E> return this;
  private var self(get,never):Belay<A,B,X,Y,R,E>;
  private function get_self():Belay<A,B,X,Y,R,E> return lift(this);

  public function mod<Ai,Bi,Xi,Yi,Ri,Ei>(fn:Proxy<A,B,X,Y,R,E>->Proxy<Ai,Bi,Xi,Yi,Ri,Ei>,?pos:Pos):Belay<Ai,Bi,Xi,Yi,Ri,Ei>{
    return lift(Fletcher._.map(this,fn,pos));
  }
  public function and_with<Ai,Aii,Bi,Bii,Xi,Xii,Yi,Yii,Ri,Rii>(that:Belay<Ai,Bi,Xi,Yi,Ri,E>,fn:Proxy<A,B,X,Y,R,E>->Proxy<Ai,Bi,Xi,Yi,Ri,E>->Proxy<Aii,Bii,Xii,Yii,Rii,E>):Belay<Aii,Bii,Xii,Yii,Rii,E>{
    return Provide._.and(
      this,
      that
    ).convert(Convert.fromFun1R(__.decouple(fn)));
  }
  @:to public function toProxy():Proxy<A,B,X,Y,R,E>{
    return Defer(this);
  }
  @:to public function toFletcher():Fletcher<Nada,Proxy<A,B,X,Y,R,E>,Nada>{
    return this;
  }
  @:from static public function fromProvide<A,B,X,Y,R,E>(self:Provide<Proxy<A,B,X,Y,R,E>>){
    return lift(self);
  }
  @:from static public function fromFletcher<A,B,X,Y,R,E>(self:Fletcher<Nada,Proxy<A,B,X,Y,R,E>,Nada>){
    return lift(self);
  }
}