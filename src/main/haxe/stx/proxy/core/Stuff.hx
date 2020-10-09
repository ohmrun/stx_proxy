package stx.proxy.core;

// class Yielder{
//   @:noUsing static public function map<A,B,X,Y,R,Y1,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Y->Y1):Proxy<A,B,X,Y1,R,E>{
//     return (function rec(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y1,R,E>{
//       return switch (prx) {
//         case Yield(y,arw) : Yield(fn(y),arw.then(map.bind(_,fn)));
//         case Await(a,arw) : Await(a,arw.then(map.bind(_,fn)));
//         case Ended(res)   : Ended(res);
//         case Defer(ft)    : Defer(ft.mod(map.bind(_,fn)));
//       }
//     })(prx);
//   }
//   // @:noUsing static public function map_a<A,B,X,Y,R,Y1,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Unary<Y,Y1>):Proxy<A,B,X,Y1,R,E>{
//   //   return (function rec(prx:Proxy<A,B,X,Y,R,E>):Proxy<A,B,X,Y1,R,E>{
//   //     return switch (prx) {
//   //       case Yield(y,arw) :
//   //         Defer(
//   //           fn.receive(y).map(
//   //             (y1) -> Yield(y1,arw.then(map_a.bind(_,fn)))
//   //           )
//   //         );
//   //       case Await(a,arw) : Await(a,arw.then(map_a.bind(_,fn)));
//   //       case Ended(res)   : Ended(res);
//   //       case Defer(ft)    : Defer(ft.map(map_a.bind(_,fn)));
//   //     }
//   //   })(prx);
//   // }
//   @:noUsing static public function tap<A,B,X,Y,R,E>(prx:Proxy<A,B,X,Y,R,E>,fn:Y->Void):Proxy<A,B,X,Y,R,E>{
//     return map(prx,function(x) {fn(x);return x;});
//   }
// }
// class Proxieds{
//   static public function then<P0,A0,B0,X0,Y0,R0,A1,B1,X1,Y1,R1,E>(lhs:Unary<P0,Proxy<A0,B0,X0,Y0,R0,E>>,rhs:Unary<R0,Proxy<A1,B1,X1,Y1,R1,E>>):Unary<P0,Proxy<A1,B1,X1,Y1,R1,E>>{
//     return (p0:P0) ->
//       lhs.then(
//         (p) -> switch(p){
//           case Ended(r) : 
//             r.fold(
//               (x)   -> __.belay(rhs.bindI(x)),
//               (e)   -> Ended(End(e)),
//               ()    -> Ended(Tap)
//             );
//         default : __.belay(then.bind(lhs,rhs));
//         }
//       );
//   }
// }