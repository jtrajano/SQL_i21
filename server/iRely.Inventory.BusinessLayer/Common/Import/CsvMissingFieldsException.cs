using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvMissingFieldsException : Exception
    {
        public IEnumerable<string> MissingFields { get; set; }

        public CsvMissingFieldsException(IEnumerable<string> missingFields)
            : this(missingFields, "One or more required fields are missing.")
        {
            
        }

        public CsvMissingFieldsException(IEnumerable<string> missingFields, string message)
            : base(message)
        {
            MissingFields = missingFields;
        }
    }
}
