using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class CsvOptions
    {
        public char Delimiter { get; set; } = CsvReader.DefaultDelimiter;
        public char Quote { get; set; } = CsvReader.DefaultQuote;
        public char Escape { get; set; } = CsvReader.DefaultEscape;
        public char Comment { get; set; } = CsvReader.DefaultComment;
        public ValueTrimmingOptions ValueTrimmingOptions { get; set; } = ValueTrimmingOptions.UnquotedOnly;
        public bool OverwriteExistingRecord { get; set; }
        public bool ContinueOnFailure { get; set; }
        public bool CheckDuplicates { get; set; } = false;
    }
}
