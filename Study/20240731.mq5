//+------------------------------------------------------------------+
//|                                                        Test1.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


//--- ORDER_MAGIC の値 
input long order_magic=55555; 
//+------------------------------------------------------------------+ 
//| スクリプトプログラムを開始する関数                                          | 
//+------------------------------------------------------------------+ 
void OnStart() 
  { 
//--- これがデモ口座であることを確かめる 
//  if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL) 
//     { 
//     Alert("Script operation is not allowed on a live account!"); 
//     return; 
//     } 
//--- 注文を出すか削除する 
  if(GetOrdersTotalByMagic(order_magic)==0)  
     { 
     //--- 現在注文はないので、注文を出す 
    uint res=SendRandomPendingOrder(order_magic); 
     Print("Return code of the trade server ",res); 
     } 
   else // 注文があるので削除する 
    { 
      DeleteAllOrdersByMagic(order_magic); 
     } 
//--- 
  } 
//+------------------------------------------------------------------+ 
//| 指定された ORDER_MAGIC で現在の注文数を受け取る                          | 
//+------------------------------------------------------------------+ 
int GetOrdersTotalByMagic(long const magic_number) 
  { 
   ulong order_ticket; 
   int total=0; 
//--- 未決注文を全部見る 
  for(int i=0;i<OrdersTotal();i++) 
     if((order_ticket=OrderGetTicket(i))>0) 
         if(magic_number==OrderGetInteger(ORDER_MAGIC)) total++; 
//--- 
   return(total); 
  } 
//+------------------------------------------------------------------+ 
//| 指定された ORDER_MAGIC  の未決注文を全て作成する                         | 
//+------------------------------------------------------------------+ 
void DeleteAllOrdersByMagic(long const magic_number) 
  { 
   ulong order_ticket; 
//--- 未決注文を全部見る 
  for(int i=OrdersTotal()-1;i>=0;i--) 
     if((order_ticket=OrderGetTicket(i))>0) 
         //--- 適切な ORDER_MAGIC を持った注文 
        if(magic_number==OrderGetInteger(ORDER_MAGIC)) 
           { 
           MqlTradeResult result={}; 
           MqlTradeRequest request={}; 
            request.order=order_ticket; 
            request.action=TRADE_ACTION_REMOVE; 
           OrderSend(request,result); 
           //--- サーバ返答をログに書く 
          Print(__FUNCTION__,": ",result.comment," reply code ",result.retcode); 
           } 
//--- 
  } 
//+------------------------------------------------------------------+ 
//| 未決注文をランダムに設定する                                            | 
//+------------------------------------------------------------------+ 
uint SendRandomPendingOrder(long const magic_number) 
  { 
//--- リクエストを準備する 
  MqlTradeRequest request={}; 
   request.action=TRADE_ACTION_PENDING;         // 未決注文を設定する  
  request.magic=magic_number;                 // ORDER_MAGIC 
   request.symbol=_Symbol;                     // シンボル 
  request.volume=0.1;                         // 0.1 ロットのボリューム 
  request.sl=0;                               // 決済逆指の指定なし 
  request.tp=0;                               // 決済指値の指定なし      
//--- 注文の種類を形成する 
  request.type=GetRandomType();               // 注文の種類 
//--- 未決注文の価格を形成する 
  request.price=GetRandomPrice(request.type); // 始値 
//--- 取引リクエストを送る 
  MqlTradeResult result={}; 
   OrderSend(request,result); 
//--- サーバ返答をログに書く   
   Print(__FUNCTION__,":",result.comment); 
   if(result.retcode==10016) Print(result.bid,result.ask,result.price); 
//--- 取引サーバの返答のコードを返す 
  return result.retcode; 
  } 
//+------------------------------------------------------------------+ 
//| 未決注文の種類をランダムに返す                                           | 
//+------------------------------------------------------------------+ 
ENUM_ORDER_TYPE GetRandomType() 
  { 
   int t=MathRand()%4; 
//---   0<=t<4 
   switch(t) 
     { 
     case(0):return(ORDER_TYPE_BUY_LIMIT); 
     case(1):return(ORDER_TYPE_SELL_LIMIT); 
     case(2):return(ORDER_TYPE_BUY_STOP); 
     case(3):return(ORDER_TYPE_SELL_STOP); 
     } 
//--- 不正な値 
  return(WRONG_VALUE); 
  } 
//+------------------------------------------------------------------+ 
//| ランダムな価格を返す                                                   | 
//+------------------------------------------------------------------+ 
double GetRandomPrice(ENUM_ORDER_TYPE type) 
  { 
   int t=(int)type; 
//--- シンボルのストップレベル 
  int distance=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL); 
//--- 最終ティックのデータを受け取る 
  MqlTick last_tick={}; 
   SymbolInfoTick(_Symbol,last_tick); 
//--- 種類に応じて価格を計算する 
  double price; 
   if(t==2 || t==5) // ORDER_TYPE_BUY_LIMIT または ORDER_TYPE_SELL_STOP 
     { 
      price=last_tick.bid; // 買値から離れる 
     price=price-(distance+(MathRand()%10)*5)*_Point; 
     } 
   else             // ORDER_TYPE_SELL_LIMIT または ORDER_TYPE_BUY_STOP 
     { 
      price=last_tick.ask; // 売値から離れる 
     price=price+(distance+(MathRand()%10)*5)*_Point; 
     } 
//--- 
   return(price); 
  }

  