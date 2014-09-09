using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCommodityGroup : BaseEntity
    {
        public int intCommodityGroupId { get; set; }
        public int intCommodityId { get; set; }
        public int intParentGroupId { get; set; }
        public int strDescription { get; set; }
        public int intSort { get; set; }
    }
}
