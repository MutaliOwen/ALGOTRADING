
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict 

input double Lots = 0.01;  
input double TslTriggerPercent = 0.5;
input double TslPercent = 0.2;
input bool IsCloseCounterSignal = true;
input double SlPercent = 0.5; 
input double TpPercent = 1.0;
 
input string Commentary = "MA crossover";
input int Magic = 1111; //helps us identify orders taken by expert advisor 
                        // for trades opened manually, the magic number is zero
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;

input int MaFastPeriods = 20;
input ENUM_MA_METHOD MaFastMethod = MODE_EMA;
input ENUM_APPLIED_PRICE MaFastPrice = PRICE_CLOSE;//enumerations -- easy to read

input int MaSlowPeriods = 50;
input ENUM_MA_METHOD MaSlowMethod = MODE_EMA;
input ENUM_APPLIED_PRICE MaSlowPrice = PRICE_CLOSE;//enumerations -- easy to read

int barsTotal;
 
int OnInit()
  {
   
   barsTotal = iBars(_Symbol,Timeframe); //returns total number of bars in the chart 
   
   return(INIT_SUCCEEDED);//initialization was successful
  }

void OnDeinit(const int reason)//event handling functons
     //event handling functions help mt4 to know when to excecute which part of the function
  {
}
void OnTick()// callledwhenever theres a tick on the chart
  {
   double maFast1 = iMA(_Symbol,Timeframe,MaFastPeriods, 0, MaFastMethod,MaFastPrice,1);
   double maFast2 = iMA(_Symbol,Timeframe,MaFastPeriods, 0, MaFastMethod,MaFastPrice,2); 
   
   double maSlow1 = iMA(_Symbol,Timeframe,MaSlowPeriods, 0, MaSlowMethod,MaSlowPrice,1);
   double maSlow2 = iMA(_Symbol,Timeframe,MaSlowPeriods, 0, MaSlowMethod,MaSlowPrice,2);
  
   for (int i = OrdersTotal()-1; i >= 0; i = i-1 ){
   
   
   
      //EA onlpy processes theorder with the matching magic number
      if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic ){
         //Print("Selected order is ",i,"! The ticket is", OrderTicket()); 
         
         if(OrderType() == OP_BUY){
         
            if(IsCloseCounterSignal && maFast1 < maSlow1){
            
            //close all the postitions with the specified magic number
               if(OrderClose(OrderTicket(),OrderLots(),Bid,100000)){
                  Print("Buy Order #",OrderTicket(),"was closed because of counter signal...");
                  continue; 
               }
            
            }
            
            if(Bid > OrderOpenPrice() +   OrderOpenPrice()* TslTriggerPercent/100){
         
               double sl = Bid - Bid * TslPercent /100;
         
               sl = NormalizeDouble(sl,_Digits);                
               
               if(sl > OrderStopLoss()){
         
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration())){
         
                     Print("Buy Order #", OrderTicket(), "was modified by TSL!!!");
                  }
                  
               }
               
               } 
         }
         
         else if(OrderType() == OP_SELL){ 
            if(IsCloseCounterSignal && maFast1 > maSlow1){
               if(OrderClose(OrderTicket(),OrderLots(),Ask,100000)){
                  Print("Sell order #",OrderTicket(),"was clossed because of counter signal");
                  continue;
               }
            
            }
            if(Ask < OrderOpenPrice() - OrderOpenPrice()*TslTriggerPercent/100){
            
               double sl = Ask + Ask* TslPercent/100 ;
               
               sl = NormalizeDouble(sl,_Digits);
            
               if(sl < OrderStopLoss() || OrderStopLoss() == 0){
               
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration())){
                  
                     Print("Sell Order #", OrderTicket(), "was modified by TSL!!!");
                  
                  }  
               
               }
            
            } 
         
         }
          
      }
      
      
      
      } 

  
  
//strategy logic
   int bars = iBars(_Symbol,Timeframe);
   if(barsTotal != bars){ 
      barsTotal = bars;
      
      //trailing the stoploss
      //var ihas its default value assigned to total orders open
      //i >= 0 is main condition...will always be true if an order is open
      //i-- i is decreased by 1....ends the loop when i < 0 
      
      /*
      for (int i = OrdersTotal()-1; i >= 0; i = i-1 ){
      
         if(OrderSelect(i,SELECT_BY_POS)){
            //Print("Selected order is ",i,"! The ticket is", OrderTicket()); 
            
            if(OrderType() == OP_BUY){
            
               if(Bid > OrderOpenPrice() +   OrderOpenPrice()* TslTriggerPercent/100){
            
                  double sl = Bid - Bid * TslPercent /100;
            
                  sl = NormalizeDouble(sl,_Digits);                
                  
                  if(sl > OrderStopLoss()){
            
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration())){
            
                        Print("Buy Order #", OrderTicket(), "was modified by TSL!!!");
                     }
                     
                  }
                  
                  } 
            }
            
            else if(OrderType() == OP_SELL){
               if(Ask < OrderOpenPrice() - OrderOpenPrice()*TslTriggerPercent/100){
               
                  double sl = Ask + Ask* TslPercent/100 ;
                  
                  sl = NormalizeDouble(sl,_Digits);
               
                  if(sl < OrderStopLoss() || OrderStopLoss() == 0){
                  
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration())){
                     
                        Print("Sell Order #", OrderTicket(), "was modified by TSL!!!");
                     
                     }  
                  
                  }
               
               } 
            
            }
             
         }
      
      
      
      } 
      
      //double ma1 = iMA(_Symbol,PERIOD_CURRENT, 20, 0, MODE_EMA,PRICE_CLOSE,1);  
      double maFast1 = iMA(_Symbol,Timeframe,MaFastPeriods, 0, MaFastMethod,MaFastPrice,1);
      double maFast2 = iMA(_Symbol,Timeframe,MaFastPeriods, 0, MaFastMethod,MaFastPrice,2); 
   
      double maSlow1 = iMA(_Symbol,Timeframe,MaSlowPeriods, 0, MaSlowMethod,MaSlowPrice,1);
      double maSlow2 = iMA(_Symbol,Timeframe,MaSlowPeriods, 0, MaSlowMethod,MaSlowPrice,2);
      */
      if(maFast1 > maSlow1 && maFast2 < maSlow2){
         //video_time_47:50
         
         Print("Buy signal!!!"); 
         executeBuy();
         
         /*
         this section is how to excecute a trade 
         double entry = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         
         double entry = Ask;
         entry = NormalizeDouble(entry,_Digits);
         
         double sl = entry - entry * SlPercent / 100;
         sl = NormalizeDouble(sl,_Digits);
         
         double tp = entry + entry * TpPercent/100;
         tp = NormalizeDouble(tp,_Digits);
         
         
        int order = OrderSend(_Symbol,OP_BUY,Lots,entry,100000,sl,tp,Commentary,Magic,0,clrBlue);
         */
         
       }else if (maFast1 < maSlow1 && maFast2 > maSlow2){
          Print("Sell Signal!!!");
          
          executeSell();
  /*        
          double entry = Bid;
          entry = NormalizeDouble(entry,_Digits);
          
          double sl = entry + entry * SlPercent / 100;
          sl = NormalizeDouble(sl,_Digits);
          
          double tp = entry - entry * TpPercent/100;
          tp = NormalizeDouble(tp,_Digits);
         
          int order = OrderSend(_Symbol,OP_SELL,Lots,entry,100000,sl,tp,Commentary,Magic,0,clrRed);
    */      
       }
      
      //chartcomment
      Comment("MA Fast 1: ",DoubleToString(maFast1,_Digits),
              "\nMa Fast 2 :",DoubleToString(maFast2,_Digits),
              "\nMa Slow 1:",DoubleToString(maSlow1,_Digits),
              "\nMa Slow 2: ",DoubleToString(maSlow2,_Digits));
              
      }
 }


//coding a function
int executeBuy () {
 
   double entry = Ask;
   entry = NormalizeDouble(entry,_Digits);
   
   double sl = entry - entry * SlPercent / 100;
   sl = NormalizeDouble(sl,_Digits);
   
   double tp = entry + entry * TpPercent/100;
   tp = NormalizeDouble(tp,_Digits);
   
   
   int order = OrderSend(_Symbol,OP_BUY,Lots,entry,100000,sl,tp,Commentary,Magic,0,clrBlue);
   
   return order;
 
 
 } 
 
 int executeSell(){
   double entry = Bid;
   entry = NormalizeDouble(entry,_Digits);
   
   double sl = entry + entry * SlPercent / 100;
   sl = NormalizeDouble(sl,_Digits);
   
   double tp = entry - entry * TpPercent/100;
   tp = NormalizeDouble(tp,_Digits);
   
   int order = OrderSend(_Symbol,OP_SELL,Lots,entry,100000,sl,tp,Commentary,Magic,0,clrRed);
  
   return order; 
 
 
 }