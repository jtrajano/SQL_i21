using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinFuelCategory : BaseEntity
    {
        public int intRinFuelCategoryId { get; set; }
        public string strRinFuelCategoryCode { get; set; }
        public string strDescription { get; set; }
        public string strEquivalenceValue { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICFuelType> RinFuelTypes { get; set; }
    }
}
