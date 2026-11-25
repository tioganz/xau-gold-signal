// XAU GOLD SIGNAL - HFM MT5 bridge (MQL5)
// Attach to XAUUSD M5 chart. Sends closed-candle indicator signal to your server.
// Set WebRequest URL in MT5: Tools > Options > Expert Advisors > Allow WebRequest.
#property strict
input string ServerURL="http://YOUR_SERVER_IP:8080/api/mt5";
input int FastEMA=9;
input int SlowEMA=21;
input int RSIPeriod=14;
input double RiskPercent=1.0;
input double RewardRisk=2.0;
int hFast,hSlow,hRSI;
datetime lastBar=0;
int OnInit(){
 hFast=iMA(_Symbol,PERIOD_M5,FastEMA,0,MODE_EMA,PRICE_CLOSE);
 hSlow=iMA(_Symbol,PERIOD_M5,SlowEMA,0,MODE_EMA,PRICE_CLOSE);
 hRSI=iRSI(_Symbol,PERIOD_M5,RSIPeriod,PRICE_CLOSE);
 if(hFast==INVALID_HANDLE||hSlow==INVALID_HANDLE||hRSI==INVALID_HANDLE) return INIT_FAILED;
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){IndicatorRelease(hFast);IndicatorRelease(hSlow);IndicatorRelease(hRSI);}
void OnTick(){
 if(_Period!=PERIOD_M5) return;
 datetime t=iTime(_Symbol,PERIOD_M5,0); if(t==lastBar) return; lastBar=t;
 double f[3],s[3],r[3]; MqlRates c[3];
 if(CopyBuffer(hFast,0,0,3,f)<3||CopyBuffer(hSlow,0,0,3,s)<3||CopyBuffer(hRSI,0,0,3,r)<3||CopyRates(_Symbol,PERIOD_M5,0,3,c)<3) return;
 // Index 1 = candle terakhir yang sudah tutup.
 string signal="WAIT",reason="Belum ada konfirmasi EMA/RSI/candle";
 bool bullish=(f[1]>s[1] && f[2]<=s[2] && r[1]>=50 && r[1]<70 && c[1].close>c[1].open);
 bool bearish=(f[1]<s[1] && f[2]>=s[2] && r[1]<=50 && r[1]>30 && c[1].close<c[1].open);
 double entry=SymbolInfoDouble(_Symbol,SYMBOL_BID),sl=0,tp=0;
 if(bullish){signal="BUY";reason="EMA bullish cross + RSI + candle bullish";entry=SymbolInfoDouble(_Symbol,SYMBOL_ASK);sl=c[1].low;tp=entry+(entry-sl)*RewardRisk;}
 if(bearish){signal="SELL";reason="EMA bearish cross + RSI + candle bearish";entry=SymbolInfoDouble(_Symbol,SYMBOL_BID);sl=c[1].high;tp=entry-(sl-entry)*RewardRisk;}
 int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
 string body=StringFormat("{\"signal\":\"%s\",\"reason\":\"%s\",\"price\":%s,\"entry\":%s,\"sl\":%s,\"tp\":%s,\"rsi\":%.2f,\"ema9\":%s,\"ema21\":%s,\"bar_time\":\"%s\"}",
 signal,reason,DoubleToString(entry,digits),DoubleToString(entry,digits),DoubleToString(sl,digits),DoubleToString(tp,digits),r[1],DoubleToString(f[1],digits),DoubleToString(s[1],digits),TimeToString(c[1].time,TIME_DATE|TIME_MINUTES));
 char post[],result[]; StringToCharArray(body,post,0,WHOLE_ARRAY,CP_UTF8); ArrayResize(post,ArraySize(post)-1);
 string headers="Content-Type: application/json\r\n"; char response[]; string response_headers;
 int code=WebRequest("POST",ServerURL,headers,5000,post,response,response_headers);
 if(code==-1) Print("WebRequest gagal: ",GetLastError()," | cek URL yang diizinkan di MT5.");
}
