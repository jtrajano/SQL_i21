using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvDataReader<T>
    {
        public CsvSchema Schema { get; set; }
        public delegate void ReadNextRecordHandler(long recordIndex, CsvRecord record, out bool succeeded);
        public event ReadNextRecordHandler ReadNextRecord;

        public CsvDataReader()
            : this(new string[] { })
        {
            
        }

        public CsvDataReader(string[] expectedFields)
        {
            Schema = new CsvSchema(expectedFields);
        }

        public async Task<bool> ReadCsvAsync(string filename, CsvOptions options = default(CsvOptions))
        {
            return await ReadCsvAsync(new StreamReader(filename), options);
        }

        public async Task<bool> ReadCsvAsync(TextReader reader, CsvOptions options = default(CsvOptions))
        {
            if (options == null)
                options = new CsvOptions();

            using (CsvReader csv = new CsvReader(reader, true, options.Delimiter, options.Quote, options.Escape, options.Comment, options.ValueTrimmingOptions))
            {
                Schema.FieldCount = csv.FieldCount;
                Schema.Fields = csv.GetFieldHeaders();

                if(await Schema.HasMissingFieldsAsync())
                {
                    throw new CsvMissingFieldsException(Schema.GetMissingFields(), 
                        "One or more required fields were missing: " + Schema.GetMissingFieldsTextRepresentation());
                }

                long currentRecordIndex = -1;

                while (csv.ReadNextRecord())
                {
                    currentRecordIndex = csv.CurrentRecordIndex;
                    var values = new Dictionary<string, string>();
                    
                    for(int i = 0; i < csv.FieldCount; i++)
                    {
                        values.Add(Schema.Fields[i], csv[i]);
                    }

                    var record = new CsvRecord()
                    {
                        Schema = Schema,
                        Values = values,
                        Index = (int) currentRecordIndex
                    };

                    bool succeeded = true;

                    OnReadNextRecord(currentRecordIndex, record, out succeeded);

                    if(options.ContinueOnFailure == false && succeeded == false)
                    {
                        return false;
                    }
                }

                return true;
            }
        }

        protected void OnReadNextRecord(long recordIndex, CsvRecord record, out bool succeeded)
        {
            succeeded = true;
            ReadNextRecord?.Invoke(recordIndex, record, out succeeded);
        }

        private string GetTextRepresentation(List<string> list)
        {
            StringBuilder sb = new StringBuilder();
            foreach (string s in list)
            {
                sb.AppendFormat("'{0}', ", s);
            }
            return sb.ToString();
        }
    }
}
