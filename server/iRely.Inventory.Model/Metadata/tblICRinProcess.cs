using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinProcess : BaseEntity
    {
        public int intRinProcessId { get; set; }
        public string strRinProcessCode { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICFuelType> RinProcesses { get; set; }
    }
}
