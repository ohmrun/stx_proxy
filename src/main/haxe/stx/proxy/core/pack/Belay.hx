package stx.proxy.core.pack;

typedef BelayDef<A,B,X,Y,R,E> = ForwardDef<Proxy<A,B,X,Y,R,E>>;

abstract Belay<A,B,X,Y,R,E>(BelayDef<A,B,X,Y,R,E>) from BelayDef<A,B,X,Y,R,E> to BelayDef<A,B,X,Y,R,E>{
  public function new(self) this = self;
  static public function lift<A,B,X,Y,R,E>(self:BelayDef<A,B,X,Y,R,E>):Belay<A,B,X,Y,R,E> return new Belay(self);
  
  @:from static public function fromThunk<A,B,X,Y,R,E>(fn:Thunk<Proxy<A,B,X,Y,R,E>>):Belay<A,B,X,Y,R,E>{
    return lazy(fn);
  }
  @:from static public function fromFuture<A,B,X,Y,R,E>(fn:Thunk<Future<Proxy<A,B,X,Y,R,E>>>):Belay<A,B,X,Y,R,E>{
    return lift(Forward.fromFunXFuture(() -> fn()));
  }
  @:noUsing static public function lazy<A,B,X,Y,R,E>(fn:Thunk<Proxy<A,B,X,Y,R,E>>):Belay<A,B,X,Y,R,E>{
    return lift(Forward.fromFunXFuture(() -> Future.async(
      (cb) -> cb(fn())
    )));
  }
  

  public function prj():BelayDef<A,B,X,Y,R,E> return this;
  private var self(get,never):Belay<A,B,X,Y,R,E>;
  private function get_self():Belay<A,B,X,Y,R,E> return lift(this);

  public function mod<Ai,Bi,Xi,Yi,Ri>(fn:Proxy<A,B,X,Y,R,E>->Proxy<Ai,Bi,Xi,Yi,Ri,E>):Belay<Ai,Bi,Xi,Yi,Ri,E>{
    return lift(Arrowlet._.postfix(this,fn));
  }
  public function and_with<Ai,Aii,Bi,Bii,Xi,Xii,Yi,Yii,Ri,Rii,E>(that:Belay<Ai,Bi,Xi,Yi,Ri,E>,fn:Proxy<A,B,X,Y,R,E>->Proxy<Ai,Bi,Xi,Yi,Ri,E>->Proxy<Aii,Bii,Xii,Yii,Rii,E>):Belay<Aii,Bii,Xii,Yii,Rii,E>{
    return Forward._.and(
      this,
      that
    ).process(__.decouple(fn));
  }
  @:to public function toProxy():Proxy<A,B,X,Y,R,E>{
    return Defer(this);
  }
  @:to public function toArrowlet():Arrowlet<Noise,Proxy<A,B,X,Y,R,E>,Noise>{
    return this;
  }
  @:from static public function fromForward<A,B,X,Y,R,E>(self:Forward<Proxy<A,B,X,Y,R,E>>){
    return lift(self);
  }
  @:from static public function fromArrowlet<A,B,X,Y,R,E>(self:Arrowlet<Noise,Proxy<A,B,X,Y,R,E>,Noise>){
    return lift(self);
  }
}