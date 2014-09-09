using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCommodityUnitMeasure : BaseEntity
    {
        public int intCommodityUnitMeasureId { get; set; }
        public int intCommodityId { get; set; }
        public int intUnitMeasureId { get; set; }
        public double dblWeightPerPack { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public int intSort { get; set; }
    }
}
