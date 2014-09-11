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
        public string strClass { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }
        public ICollection<tblICCategoryVendor> VendorSells { get; set; }
        public ICollection<tblICCategoryVendor> VendorOrders { get; set; }
        
    }
}
