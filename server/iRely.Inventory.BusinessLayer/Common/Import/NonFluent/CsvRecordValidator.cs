using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvRecordValidator<T> : CsvRecordHandler<T>
    {
        public override T ProcessRecord(CsvRecord record)
        {
            if(CanHandle(record))
            {
                return default(T);
            }
            else if(_next != null)
            {
                return _next.ProcessRecord(record);
            }
            return default(T);
        }

        public override async Task<T> ProcessRecordAsync(CsvRecord record)
        {
            return await Task.Run(() => ProcessRecord(record));
        }

        public bool CanHandle(CsvRecord record)
        {
            return true;
        }
    }
}
