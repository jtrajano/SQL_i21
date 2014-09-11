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
        public string strFamily { get; set; }
        public string strDesciption { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }

    }
}
