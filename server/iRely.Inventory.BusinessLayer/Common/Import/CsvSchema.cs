using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvSchema
    {
        public int FieldCount { get; set; }
        public string[] Fields { get; set; }
        public string[] _expectedFields { get; set; }
        
        public CsvSchema(string[] expectedFields)
        {
            _expectedFields = expectedFields;
        }

        public async Task<bool> HasMissingFieldsAsync()
        {
            return await Task.Run(() => HasMissingFields());
        }

        public bool HasMissingFields()
        {
            if (_expectedFields.Length == 0)
                return false;
            if(Fields.Length > 0)
            {
                return _expectedFields.Intersect(Fields, new FieldHeaderComparer()).Count() != _expectedFields.Count();
            }

            return false;
        }

        public IEnumerable<string> GetMissingFields()
        {
            return _expectedFields.Except(Fields);
        }

        public string GetMissingFieldsTextRepresentation(bool camelize = true)
        {
            var missingFields = GetMissingFields();
            StringBuilder sb = new StringBuilder();
            foreach(string s in missingFields)
            {
                sb.AppendFormat("'{0}', ", s);
            }
            return camelize ? CultureInfo.CurrentCulture.TextInfo.ToTitleCase(sb.ToString().Substring(0, sb.Length - 2)) : sb.ToString().Substring(0, sb.Length - 2);
        }

        private class FieldHeaderComparer : IEqualityComparer<string>
        {
            public bool Equals(string x, string y)
            {
                return x.ToLowerInvariant().Equals(y.ToLowerInvariant());
            }

            public int GetHashCode(string obj)
            {
                return obj.ToLowerInvariant().GetHashCode();
            }
        }
    }
}
