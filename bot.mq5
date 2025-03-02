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
input int hour_start = 17;      // زمان شروع

//--------------------------------------------------------------------------------------------
int OnInit(){
	//---------
   	if (Period() != 5){
		Alert("فقط در تایم فریم 5 دقیقه فعال می باشد");
		ExpertRemove();
	}
	//---------
   	return(INIT_SUCCEEDED);
}
//--------------------------------------------------------------------------------------------
void OnTick(){
	datetime currentTime = TimeCurrent();
	datetime startTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(hour_start) + ":00");
	datetime endTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(hour_start) + ":10");
	
	double my_open = iOpen(NULL, 0, 1);
	double my_close = iClose(NULL, 0, 1);
	datetime my_time = iTime(NULL, 0, 1);

	double tempHighPrice = 0;
	double tempLowPrice = 0;

	string my_symbol = Symbol();

	int my_count = 2;
	//-----------------------------------------------
	if(currentTime == startTime){
		drow_lins = false;
		show_alert = false;
		highestPrice = 0;
		lowestPrice = 0;
	}
	//-----------------------------------------------
	if(Symbol() == "XAUUSD"){
		my_count = 7;
		endTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(hour_start) + ":35");
	}
	//-----------------------------------------------
	if ((currentTime >= startTime) && (currentTime <= endTime) && (!drow_lins)){
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
		myPrint(my_symbol + " | Long | " + TimeToString(my_time,TIME_DATE|TIME_SECONDS));
	if((my_close < lowestPrice) && (drow_lins) && (!show_alert))
		myPrint(my_symbol + " | Short | " + TimeToString(my_time,TIME_DATE|TIME_SECONDS));
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



//-------------------------------------------------------------------------------------------------------------------------
//                                                                                                                        |
//                                                 Send Message To Telegram                                               |
//                                                   Samad Elmakchi (SMD)                                                 |
//                                                                                                                        |
//   Tools -> Options -> Expert Advisors -> Allow WebRequest for listed URL: -> Add -> https://api.telegram.org -> OK     |
//                                                                                                                        |
//   How To Used                                                                                                          |
//   SendTelegramMessage("My Message"); // no image attached                                                              |
//                                                                                                                        |
//   ChartScreenShot(0, "MyScreenshot.bmp", 1024, 768, ALIGN_RIGHT);                                                      |
//   SendTelegramMessage("Message", "MyScreenshot.jpg");                                                                  |                                
//                                                                                                                        |
//-------------------------------------------------------------------------------------------------------------------------
const string TelegramBotToken = "7662953174:AAES-D9JLPiHZ2NF_yTihDGdchEhC_EwNFw";  // Your Bot ID -> BotFather
const string ChatId           = "-1002284392265";                                  // Your Telegram ID -> Get Telegram ID Bot
const string TelegramApiUrl   = "https://api.telegram.org"; // Add This To Allow URLs
const int    UrlDefinedError  = 4014;                       // MT4: 4066 - MT5: 4014
//-------------------------------------------------------------------------------------------------------------------------
bool SendTelegramMessage(string text, string fileName = ""){
	string headers    = "";
	string requestUrl = "";
	char   postData[];
	char   resultData[];
	string resultHeaders;
	int    timeout = 5000; // 1 second, may be too short for a slow connection
	//------
	ResetLastError();
	if(fileName == ""){
		requestUrl = StringFormat("%s/bot%s/sendmessage?chat_id=%s&text=%s", TelegramApiUrl, TelegramBotToken, ChatId, text);
	}
	else {
		requestUrl = StringFormat("%s/bot%s/sendPhoto", TelegramApiUrl, TelegramBotToken);
		if(!GetPostData(postData, headers, ChatId, text, fileName)){
			return(false);
		}
	}
	//------
	ResetLastError();
	int response = WebRequest("POST", requestUrl, headers, timeout, postData, resultData, resultHeaders);
	switch(response){
		case -1:{
			int errorCode = GetLastError();
			Print("Error in WebRequest. Error code  =", errorCode);
			if(errorCode == UrlDefinedError){
				//--- url may not be listed
				PrintFormat("Add the address '%s' in the list of allowed URLs", TelegramApiUrl);
			}
			break;
		}
		case 200:
			//--- Success
			Print("The message has been successfully sent");
			break;
		default:{
			string result = CharArrayToString(resultData);
			PrintFormat("Unexpected Response '%i', '%s'", response, result);
			break;
		}
	}
	return(response == 200);
}
//-------------------------------------------------------------------------------------------------------------------------
bool GetPostData(char &postData[], string &headers, string chat, string text, string fileName){
	ResetLastError();
	//------
	if(!FileIsExist(fileName)){
		PrintFormat("File '%s' does not exist", fileName);
		return(false);
	}
	//------
	int flags = FILE_READ | FILE_BIN;
	int file  = FileOpen(fileName, flags);
	if(file == INVALID_HANDLE){
		int err = GetLastError();
		PrintFormat("Could not open file '%s', error=%i", fileName, err);
		return(false);
	}
	//------
	int   fileSize = (int)FileSize(file);
	uchar photo[];
	ArrayResize(photo, fileSize);
	FileReadArray(file, photo, 0, fileSize);
	FileClose(file);
	//------
	string hash = "";
	AddPostData(postData, hash, "chat_id", chat);
	if(StringLen(text) > 0){
		AddPostData(postData, hash, "caption", text);
	}
	AddPostData(postData, hash, "photo", photo, fileName);
	ArrayCopy(postData, "--" + hash + "--\r\n");
	//------
	headers = "Content-Type: multipart/form-data; boundary=" + hash + "\r\n";
	//------
	return(true);
}
//-------------------------------------------------------------------------------------------------------------------------
void AddPostData(uchar &data[], string &hash, string key = "", string value = ""){
	uchar valueArr[];
	StringToCharArray(value, valueArr, 0, StringLen(value));
	AddPostData(data, hash, key, valueArr);
	return;
}
//-------------------------------------------------------------------------------------------------------------------------
void AddPostData(uchar &data[], string &hash, string key, uchar &value[], string fileName = ""){
	if(hash == ""){
		hash = Hash();
	}
	ArrayCopy(data, "\r\n");
	ArrayCopy(data, "--" + hash + "\r\n");
	if(fileName == ""){
		ArrayCopy(data, "Content-Disposition: form-data; name=\"" + key + "\"\r\n");
	}
	else{
		ArrayCopy(data, "Content-Disposition: form-data; name=\"" + key + "\"; filename=\"" + fileName + "\"\r\n");
	}
	ArrayCopy(data, "\r\n");
	ArrayCopy(data, value, ArraySize(data));
	ArrayCopy(data, "\r\n");
	return;
}
//-------------------------------------------------------------------------------------------------------------------------
void ArrayCopy(uchar &dst[], string src){
	uchar srcArray[];
	StringToCharArray(src, srcArray, 0, StringLen(src));
	ArrayCopy(dst, srcArray, ArraySize(dst), 0, ArraySize(srcArray));
	return;
}
//-------------------------------------------------------------------------------------------------------------------------
string Hash(){
	uchar  tmp[];
	string seed = IntegerToString(TimeCurrent());
	int    len  = StringToCharArray(seed, tmp, 0, StringLen(seed));
	string hash = "";
	for(int i=0; i<len; i++)
		hash += StringFormat("%02X", tmp[i]);
	hash = StringSubstr(hash, 0, 16);
	return(hash);
}
//-------------------------------------------------------------------------------------------------------------------------