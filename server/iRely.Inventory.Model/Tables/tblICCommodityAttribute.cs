using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCommodityAttribute : BaseEntity
    {
        public int intCommodityAttributeId { get; set; }
        public int intCommodityId { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }

        public tblICCommodity tblICCommodity { get; set; }
    }
}
