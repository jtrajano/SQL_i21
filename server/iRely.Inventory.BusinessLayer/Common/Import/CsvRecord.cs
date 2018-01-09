using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvRecord
    {
        public int RecordNo {  get { return Index + 2; } } // + Header row
        public int Index { get; set; } = -1;
        public Dictionary<string, string> Values { get; set; }
        public CsvSchema Schema { get; set; }
        public string GetStringValuesFromRequiredFields(string[] requiredfields)
        {
            var sb = new StringBuilder();
            foreach (string s in requiredfields)
            {
                var header = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(s.Trim());
                var val = $"value of '{s}'";
                try
                {
                    val = this[header];
                }
                catch
                {

                }
                sb.AppendFormat("'{0}', ", val);
            }
            return sb.ToString();
        }

        public string this[string key]
        {
            get
            {
                return Values[key];
            }
        }
    }
}
