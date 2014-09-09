using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICClass : BaseEntity
    {
        public int intClassId { get; set; }
        public int strClass { get; set; }
        public int strDescription { get; set; }
        public int intSort { get; set; }
    }
}
