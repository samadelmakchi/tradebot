using System;
using NinjaTrader.Cbi;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
using NinjaTrader.NinjaScript.Strategies;
using NinjaTrader.NinjaScript.StrategyAnalyzer;
using NinjaTrader.NinjaScript.StrategyGenerator;
using NinjaTrader.NinjaScript.StrategyAnalyzer;

namespace NinjaTrader.Strategies
{
    public class Hamed2 : Strategy
    {
        private double highestPrice = 0;
        private double lowestPrice = 0;
        private bool drow_lins = false;
        private bool show_alert = false;
        private int hour_start = 17;  // زمان شروع

        protected override void OnStartUp()
        {
            // مطمئن شوید که تایم فریم 5 دقیقه است
            if (BarsPeriod.Id != MarketDataType.Minute || BarsPeriod.Value != 5)
            {
                Print("فقط در تایم فریم 5 دقیقه فعال می باشد");
                Stop();
            }
        }

        protected override void OnBarUpdate()
        {
            DateTime currentTime = Time[0];
            DateTime startTime = new DateTime(currentTime.Year, currentTime.Month, currentTime.Day, hour_start, 0, 0);
            DateTime endTime = new DateTime(currentTime.Year, currentTime.Month, currentTime.Day, hour_start, 10, 0);

            if (currentTime >= startTime && currentTime <= endTime && !drow_lins)
            {
                highestPrice = High[1];
                lowestPrice = Low[1];
                int my_count = 2;

                if (Instrument.FullName == "XAUUSD")
                {
                    my_count = 7;
                    endTime = new DateTime(currentTime.Year, currentTime.Month, currentTime.Day, hour_start, 35, 0);
                }

                for (int i = 1; i <= my_count; i++)
                {
                    double tempHighPrice = High[i];
                    double tempLowPrice = Low[i];
                    if (tempHighPrice > highestPrice)
                        highestPrice = tempHighPrice;
                    if (tempLowPrice < lowestPrice)
                        lowestPrice = tempLowPrice;
                }

                if (currentTime == endTime)
                    my_drow_line();
            }

            // بررسی برای اعلام سیگنال‌ها
            if (Closes[0][0] > highestPrice && drow_lins && !show_alert)
                myPrint(Instrument.FullName + " | Long | " + Time[0].ToString("yyyy-MM-dd HH:mm:ss"));
            if (Closes[0][0] < lowestPrice && drow_lins && !show_alert)
                myPrint(Instrument.FullName + " | Short | " + Time[0].ToString("yyyy-MM-dd HH:mm:ss"));
        }

        private void my_drow_line()
        {
            drow_lins = true;
            
            // ترسیم خطوط
            Draw.HorizontalLine(this, "HighestLine" + highestPrice, highestPrice, System.Windows.Media.Brushes.Green);
            Draw.HorizontalLine(this, "LowestLine" + lowestPrice, lowestPrice, System.Windows.Media.Brushes.Crimson);
        }

        private void myPrint(string message)
        {
            show_alert = true;
            Print(message);
            Alert(message, Priority.High);
        }
    }
}

