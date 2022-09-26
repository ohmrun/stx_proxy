package stx.proxy.core;

typedef ServerDef<X,Y,R,E> = ProxySum<Closed,Noise,X,Y,R,E>;

@:using(stx.proxy.core.Server.ServerLift)
@:forward
@:transitive abstract Server<X,Y,R,E>(ServerDef<X,Y,R,E>) from ServerDef<X,Y,R,E> to ServerDef<X,Y,R,E>{
  static public var _(default,never) = ServerLift;
  public function new(v:ServerDef<X,Y,R,E>){
    this = v;
  }
  @:noUsing static public function lift<X,Y,R,E>(self:ServerDef<X,Y,R,E>){
    return new Server(self);
  }
  public function prj():ServerDef<X,Y,R,E>{
    return this;
  }
  public function reflect():Client<Y,X,R,E>{
    return Client.lift(Proxy._.reflect(this));
  }
}
class ServerLift{
  static public function provide<X,Y,R,E>(self:ProxySum<Closed,Noise,X,Y,R,E>,x:X):Server<X,Y,R,E>{
    function rec(self:ProxySum<Closed,Noise,X,Y,R,E>,x:X):Proxy<Closed,Noise,X,Y,R,E>{
      return switch(self){
        case Yield(y,fn)    : __.yield(y,
          (xI:X) -> {
            var res = fn(x);
            return Proxy.lift(rec(res,xI));
          }
        );
        case Await(a,fn)    : __.await(a,fn.then(rec.bind(_,x)));
        case Defer(pr)      : __.belay(pr.map(rec.bind(_,x)));
        case Ended(chk)     : 
          //TODO ProxyFailure
          __.ended(chk);
      };
    }
    return Server.lift(rec(self,x));
  }
  static public function next<X,Y,C,D,R,E>(self:ProxySum<Closed,Noise,X,Y,R,E>,fn:Unary<Y,Proxy<X,Y,C,D,R,E>>):Server<C,D,R,E>{
    return Server.lift(PushCat._.next(self,fn));
  }
  static public function connect<X,Y,C,D,R,E>(self:ProxySum<Closed,Noise,X,Y,R,E>,fn:Unary<Y,ProxySum<X,Y,Noise,Closed,R,E>>):Outlet<R,E>{
    return Outlet.lift(next(self,fn));
  }
  // static public function drive<A,B,X,Y,R,E>(self:ProxySum<Closed,Noise,X,Y,R,E>,that:ProxySum<X,Y,Noise,Closed,R,E>){
  //   return switch(that){
  //     case Yield(_,fn)  : 
  //       drive(self,fn(Noise));
  //     case Await(y,fn)  : 
  //       final next = provide(self,y);
  //       null;
  //     case Defer(pr)    : __.belay(pr.map(drive.bind(self)));
  //     case Ended(chk)   : __.ended(chk);
  //   };
  // }
}