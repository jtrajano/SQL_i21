using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public struct ImportDataMessage
    {
        public int Row { get; set; }
        public string Column { get; set; }
        public string Message { get; set; }
        public string Type { get; set; }
        public string Status { get; set; }
        public Exception Exception { get; set; }
    }
}
