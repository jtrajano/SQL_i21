using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvPipe<T> : PipeBase<T>
    {
        public CsvPipe(DbContext context, ImportDataResult result)
        {
            Context = context;
            Result = result;
        }

        public CsvRecord Record
        {
            get { return CurrentRecordTracker.Instance.Record; }
        }

        public ImportDataResult Result { get; }
        public DbContext Context { get; }

        protected override T Process(T input)
        {
            return input;
        }

        protected string GetFieldValue(string key, string defaultValue = null)
        {
            return ImportDataLogicHelpers.GetFieldValue(Record, key, defaultValue);
        }

        protected void AddWarning(string header, string message, string value = null)
        {
            AddMessage(header, message, value, Constants.TYPE_WARNING);
        }

        protected void AddError(string header, string message, string value = null)
        {
            AddMessage(header, message, value, Constants.TYPE_ERROR);
        }

        protected void AddMessage(string header, string message, 
            string value = null, 
            string type = Constants.TYPE_WARNING, 
            string status = Constants.STAT_FAILED, 
            string action = Constants.ACTION_SKIPPED)
        {
            value = value == null ? GetFieldValue(header, "") : value;

            var msg = new ImportDataMessage()
            {
                Column = header,
                Row = Record.RecordNo,
                Type = type,
                Status = status,
                Action = action,
                Exception = null,
                Value = value,
                Message = message
            };
            if(Result != null)
                Result.AddError(msg);
        }
    }
}
