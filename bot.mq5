//--------------------------------------------------------------------------------------------
//                                                                                   bot.mq5 |
//                                                                            Samad Elmakchi |
//                                                                   https://www.elmakchi.ir |
//--------------------------------------------------------------------------------------------
#property copyright   "Samad Elmakchi"
#property link        "https://www.elmakchi.ir"
#property version     "1.00"
#property icon        "icon.ico"

bool drow_lins = false;
bool show_alert = false;
double highestPrice = 0;
double lowestPrice = 0;

//--------------------------------------------------------------------------------------------

input group "تنظیمات عمومی"; 
input int hour_start = 17;                                                           // زمان شروع
input string telegram_bot_token = "7861695393:AAHcinMI-jDObsOeZ26xoHPjr1mIJHZ5EUw";  // توکن ربات تلگرام
input string telegram_chat_id = "-1002461252694";                                    // آیدی چت یا گروه تلگرام

//--------------------------------------------------------------------------------------------
int OnInit(){
	//---------
   	if (Period() != 5){
		Alert("فقط در تایم فریم 5 دقیقه فعال می باشد");
		ExpertRemove();
	}
	//---------
	Print("📈Start Bot📉");
	SendTelegramMessage("📈Start Bot📉");
	//---------
   	return(INIT_SUCCEEDED);
}
//--------------------------------------------------------------------------------------------
void OnTick(){
	datetime currentTime = TimeLocal();
	currentTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + TimeToString(currentTime,TIME_MINUTES));
	datetime startTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(hour_start) + ":00");
	datetime endTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(hour_start) + ":05");
	
	double my_open = iOpen(NULL, 0, 1);
	double my_close = iClose(NULL, 0, 1);
	datetime my_time = iTime(NULL, 0, 1);

	double tempHighPrice = 0;
	double tempLowPrice = 0;

	string my_symbol = Symbol();

	int my_count = 1;
	//-----------------------------------------------
	if(currentTime == startTime){
		drow_lins = false;
		show_alert = false;
		highestPrice = 0;
		lowestPrice = 0;
	}
	//-----------------------------------------------
	if(Symbol() == "XAUUSD"){
		my_count = 6;
		endTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(hour_start) + ":30");
	}
	//-----------------------------------------------
	if ((currentTime == endTime) && (!drow_lins)){
		highestPrice = iHigh(NULL, 0, 1);
		lowestPrice = iLow(NULL, 0, 1);
		for(int i=1;i<=my_count;i++){
			tempHighPrice = iHigh(NULL, 0, i);
			tempLowPrice = iLow(NULL, 0, i);
			if(tempHighPrice > highestPrice)
				highestPrice = tempHighPrice;
			if(tempLowPrice < lowestPrice)
				lowestPrice = tempLowPrice;
		}
		if(currentTime == endTime)
			my_drow_line();
	}
	//-----------------------------------------------	
	if((my_close > highestPrice) && (drow_lins) && (!show_alert))
		myPrint("📈 Long | " + my_symbol + " | " + TimeToString(my_time,TIME_DATE|TIME_SECONDS));
	if((my_close < lowestPrice) && (drow_lins) && (!show_alert))
		myPrint("📉 Short | " + my_symbol + " | " + TimeToString(my_time,TIME_DATE|TIME_SECONDS));
}
//--------------------------------------------------------------------------------------------
void my_drow_line(){
    long chart_ID = ChartID();
	drow_lins = true;
	//-----------------------------------------------
	int obj_count = ObjectsTotal(chart_ID,-1,OBJ_HLINE);
	for (int i=obj_count-1; i>=0; i--){
		string line_name = ObjectName(chart_ID, i, -1, OBJ_HLINE);
		ObjectDelete(chart_ID, line_name);
	}
	//-----------------------------------------------
    string obj_name = DoubleToString(highestPrice) + IntegerToString(MathRand());
	if(ObjectCreate(chart_ID, obj_name, OBJ_HLINE, 0, 0, highestPrice)){
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_COLOR,clrGreen);        // line color
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_RAY_RIGHT,false);         // line's continuation to the right
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_STYLE,STYLE_DASH);        // line style
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_WIDTH,1);                 // line width
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_BACK,false);              // in the background
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_SELECTABLE,true);         // highlight to move
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_SELECTED,false);
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_HIDDEN,false);            // hidden in the object list
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_ZORDER,0);                // priority for mouse click         
	}
	else
		Print("Error: can't create trend line! code = " + IntegerToString(GetLastError()));
	//-----------------------------------------------
    obj_name = DoubleToString(lowestPrice) + IntegerToString(MathRand());
	if(ObjectCreate(chart_ID, obj_name, OBJ_HLINE, 0, 0, lowestPrice)){
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_COLOR,clrCrimson);      // line color
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_RAY_RIGHT,false);         // line's continuation to the right
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_STYLE,STYLE_DASH);        // line style
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_WIDTH,1);                 // line width
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_BACK,false);              // in the background
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_SELECTABLE,true);         // highlight to move
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_SELECTED,false);
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_HIDDEN,false);            // hidden in the object list
		ObjectSetInteger(chart_ID,obj_name,OBJPROP_ZORDER,0);                // priority for mouse click         
	}
	else
		Print("Error: can't create trend line! code = " + IntegerToString(GetLastError()));
	//-----------------------------------------------
}
//--------------------------------------------------------------------------------------------
void myPrint(string tstr){
	show_alert = true;
	Print(tstr);
	Alert(tstr);
	SendNotification(tstr);
	SendTelegramMessage(tstr);
}
//--------------------------------------------------------------------------------------------
// Tools -> Options -> Expert Advisors -> Allow WebRequest for listed URL: -> Add -> https://api.telegram.org -> OK 
void SendTelegramMessage(string message){
	string url = "https://api.telegram.org/bot" + telegram_bot_token + "/sendMessage";
    string headers = "Content-Type: application/x-www-form-urlencoded";
    string postData = "chat_id=" + telegram_chat_id + "&text=" + message;
	char postDataArray[];
	int postDataSize = StringToCharArray(postData, postDataArray) - 1;  
	char result[];
	string result_headers;

	int response = WebRequest("POST", url, headers, "", 5000, postDataArray, postDataSize, result, result_headers);
	if(response == -1)
		Print("❌ خطا در ارسال پیام به تلگرام: ", GetLastError());
	else
		Print("✅ پیام به تلگرام ارسال شد: ", message);

    // int result_code = WebRequest("POST", url, headers, 5000, postDataArray, result, result_headers);
    // if (result_code == 200)
    //     Print("✅ پیام به تلگرام ارسال شد: ", message);
    // else
    //     Print("❌ خطا در ارسال پیام به تلگرام: ", GetLastError());
}
//--------------------------------------------------------------------------------------------
