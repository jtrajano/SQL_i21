using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategoryAccount : BaseEntity
    {
        public int intCategoryAccountId { get; set; }
        public int intCategoryId { get; set; }
        public int intLocationId { get; set; }
        public int intStoreId { get; set; }
        public int strAccountDescription { get; set; }
        public int intAccountId { get; set; }
    }
}
