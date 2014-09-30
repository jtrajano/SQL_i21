using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemStock : BaseEntity
    {
        public int intItemStockId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strWarehouse { get; set; }
        public int intUnitMeasureId { get; set; }
        public double dblUnitOnHand { get; set; }
        public double dblOrderCommitted { get; set; }
        public double dblOnOrder { get; set; }
        public double dblReorderPoint { get; set; }
        public double dblMinOrder { get; set; }
        public double dblSuggestedQuantity { get; set; }
        public double dblLeadTime { get; set; }
        public string strCounted { get; set; }
        public string strInventoryGroup { get; set; }
        public bool ysnCountedDaily { get; set; }
        public int intSort { get; set; }
        public int intConcurrencyId { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
