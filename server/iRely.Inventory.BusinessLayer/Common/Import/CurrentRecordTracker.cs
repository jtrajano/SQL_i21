using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public sealed class CurrentRecordTracker
    {
        private static CurrentRecordTracker instance;

        private CurrentRecordTracker() { }

        public static CurrentRecordTracker Instance
        {
            get
            {
                if (instance == null)
                    instance = new CurrentRecordTracker();
                return instance;
            }
        }

        private CsvRecord _record;
        public CsvRecord Record { get { return _record; } set { _record = value; } }
        public int TotalRecords { get; set; }
        public DateTime TimeStart { get; set; }
        public DateTime TimeFinished { get; set; }

        public double TimeElapsed
        {
            get
            {
                return ((double) TimeFinished.Subtract(TimeStart).TotalMilliseconds) / 1000.0d;
            }
        }
    }
}
