using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICPatronageCategory : BaseEntity
    {
        public int intPatronageCategoryId { get; set; }
        public int strCategoryCode { get; set; }
        public int strDescription { get; set; }
        public int strPurchaseSale { get; set; }
        public int strUnitAmount { get; set; }
        public int intSort { get; set; }
    }
}
