using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportDataResult
    {
        public string Info { get; set; }
        public string Description { get; set; }
        private List<ImportDataMessage> messages;
        public bool IsUpdate { get; set; }
        public int Rows { get; set; }

        public ImportDataResult()
        {
            messages = new List<ImportDataMessage>();
        }

        public List<ImportDataMessage> Messages
        {
            get { return messages; }
            set { messages = value; }
        }
    }
}
