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
        public string strCategoryCode { get; set; }
        public string strDescription { get; set; }
        public string strPurchaseSale { get; set; }
        public string strUnitAmount { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICCommodity> tblICCommodities { get; set; }
        public ICollection<tblICCommodity> tblICCommoditiesDirect { get; set; }


    }
}
