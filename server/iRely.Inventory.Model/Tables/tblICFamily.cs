using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICFamily : BaseEntity
    {
        public int intFamilyId { get; set; }
        public int strFamily { get; set; }
        public int strDesciption { get; set; }
        public int intSort { get; set; }
    }
}
