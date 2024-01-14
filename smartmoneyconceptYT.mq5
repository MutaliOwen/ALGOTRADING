
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
 
#property indicator_label1 "High"
#property indicator_color1 clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_ARROW

#property indicator_label2 "Low"
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_ARROW

input int Depth = 20; //check whether to change

double highs[], lows[]; //can store multiple values --- array

int lastDirection = 0;
datetime lastTimeH = 0; // store time of last high and low 
datetime lastTimeL = 0;
datetime prevTimeH = 0;
datetime prevTimeL = 0;
 
 

int OnInit(){
   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   SetIndexBuffer(0,highs,INDICATOR_DATA);
   
   SetIndexBuffer(1,lows,INDICATOR_DATA);
   
   ArraySetAsSeries(highs,true);
   ArraySetAsSeries(lows,true);
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
   
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   return(INIT_SUCCEEDED);
 
 
  }
  
  
void OnDeinit(const int reason){
ObjectsDeleteAll(0,"SMC");

}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   
   
   int limit = rates_total - prev_calculated;
   limit = MathMin(limit,rates_total - Depth*2-1); //not address index not available
 

   for(int i = limit; i > 0; i--){
      highs[i] = EMPTY_VALUE;
      lows[i] = EMPTY_VALUE;
      
      int indexLastH = iBarShift(_Symbol,PERIOD_CURRENT,lastTimeH);
      int indexLastL = iBarShift(_Symbol,PERIOD_CURRENT,lastTimeL);
      int indexPrevH = iBarShift(_Symbol,PERIOD_CURRENT,prevTimeH);
      int indexPrevL = iBarShift(_Symbol,PERIOD_CURRENT,prevTimeL);
      
      if(indexLastH > 0 && indexLastL > 0 && indexPrevH > 0 && indexPrevL > 0){
         if(high[indexLastH] > high[indexPrevH] && low[indexLastL] > low[indexPrevL]){
            if(close[i] > high[indexLastH]){
               string objName = "SMC BOS" + TimeToString(time[indexLastH]);
               if(ObjectFind(0, objName) < 0) ObjectCreate(0,objName,OBJ_TREND,0,time[indexLastH],high[indexLastH],time[i],high[indexLastH]);
            }
         }
      
         if(high[indexLastH] < high[indexPrevH] && low[indexLastL] < low[indexPrevL]){
            if(close[i] < low[indexLastL]){
               string objName = "SMC BOS" + TimeToString(time[indexLastL]);
               if(ObjectFind(0, objName) < 0) ObjectCreate(0,objName,OBJ_TREND,0,time[indexLastL],low[indexLastL],time[i],low[indexLastL],clrBlue);
            }
         }
      
      
      }
      
      
      if(i+Depth == ArrayMaximum(high,i,Depth*2)){
         if(lastDirection > 0 ){
            //int index = iBarShift(_Symbol,PERIOD_CURRENT,lastTimeH);
            if(high[indexLastH] < high[i+ Depth]) highs[indexLastH] = EMPTY_VALUE;
            else continue; 
         }
         
         highs[i+Depth] = high[i+Depth];
         lastDirection = 1;
         if(indexLastH == -1 ||highs[indexLastH] != EMPTY_VALUE) prevTimeH = lastTimeH;
         lastTimeH = time[i + Depth]; 
      
      }

       if(i+Depth == ArrayMinimum(low,i,Depth*2)){
          if(lastDirection < 0 ){
            //int index = iBarShift(_Symbol,PERIOD_CURRENT,lastTimeL);
            if(low[indexLastL] < low[i+ Depth]) lows[indexLastL] = EMPTY_VALUE;
            else continue; 
         }
         
         lows[i+Depth] = low[i+Depth];
         lastDirection = -1 ;
         // time stamp of the last two highs and lows 
         if(indexLastL == -1 || lows[indexLastL] != EMPTY_VALUE)prevTimeL = lastTimeL;
         lastTimeL = time[i+Depth];
      }

   }

   return(rates_total);
  }
