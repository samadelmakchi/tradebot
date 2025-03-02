using cAlgo.API;
using System;

namespace cAlgo.Strategies
{
    public class Hamed2 : Strategy
    {
        private double highestPrice = 0;
        private double lowestPrice = 0;
        private bool drow_lins = false;
        private bool show_alert = false;
        private int hour_start = 17;  // زمان شروع

        protected override void OnStart()
        {
            // مطمئن شوید که تایم فریم 5 دقیقه است
            if (TimeFrame != TimeFrame.Minute5)
            {
                Print("فقط در تایم فریم 5 دقیقه فعال می باشد");
                Stop();
            }
        }

        protected override void OnBar()
        {
            DateTime currentTime = Server.Time;
            DateTime startTime = new DateTime(currentTime.Year, currentTime.Month, currentTime.Day, hour_start, 0, 0);
            DateTime endTime = new DateTime(currentTime.Year, currentTime.Month, currentTime.Day, hour_start, 10, 0);

            if (currentTime >= startTime && currentTime <= endTime && !drow_lins)
            {
                highestPrice = MarketSeries.High.Last(1);
                lowestPrice = MarketSeries.Low.Last(1);
                int my_count = 2;

                if (Symbol.Name == "XAUUSD")
                {
                    my_count = 7;
                    endTime = new DateTime(currentTime.Year, currentTime.Month, currentTime.Day, hour_start, 35, 0);
                }

                for (int i = 1; i <= my_count; i++)
                {
                    double tempHighPrice = MarketSeries.High.Last(i);
                    double tempLowPrice = MarketSeries.Low.Last(i);
                    if (tempHighPrice > highestPrice)
                        highestPrice = tempHighPrice;
                    if (tempLowPrice < lowestPrice)
                        lowestPrice = tempLowPrice;
                }

                if (currentTime == endTime)
                    my_drow_line();
            }

            // بررسی برای اعلام سیگنال‌ها
            if (MarketSeries.Close.Last(0) > highestPrice && drow_lins && !show_alert)
                myPrint(Symbol.Name + " | Long | " + currentTime.ToString("yyyy-MM-dd HH:mm:ss"));
            if (MarketSeries.Close.Last(0) < lowestPrice && drow_lins && !show_alert)
                myPrint(Symbol.Name + " | Short | " + currentTime.ToString("yyyy-MM-dd HH:mm:ss"));
        }

        private void my_drow_line()
        {
            drow_lins = true;

            // ترسیم خطوط
            Chart.DrawHorizontalLine("HighestLine" + highestPrice, highestPrice, Color.Green);
            Chart.DrawHorizontalLine("LowestLine" + lowestPrice, lowestPrice, Color.Crimson);
        }

        private void myPrint(string message)
        {
            show_alert = true;
            Print(message);
            // ارسال هشدار (در cTrader نیازی به اعلان خاص نیست، می‌توانید از MessageBox یا ارسال ایمیل استفاده کنید)
            SendEmail("Alert: " + message);
        }
    }
}
