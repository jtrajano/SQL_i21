using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinFuel : BaseEntity
    {
        public int intRinFuelId { get; set; }
        public int strRinFuelCode { get; set; }
        public int strDescription { get; set; }
        public int intSort { get; set; }
    }
}
