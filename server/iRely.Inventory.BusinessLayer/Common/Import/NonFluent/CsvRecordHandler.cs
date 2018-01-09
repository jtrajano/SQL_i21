using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public abstract class CsvRecordHandler<T>
    {
        protected CsvRecordHandler<T> _next;

        public abstract T ProcessRecord(CsvRecord record);

        public abstract Task<T> ProcessRecordAsync(CsvRecord record);

        public void Next(CsvRecordHandler<T> next)
        {
            _next = next;
        }
    }
}
