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
        public string strRinFuelCode { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICFuelType> RinFuels { get; set; }
    }
}
