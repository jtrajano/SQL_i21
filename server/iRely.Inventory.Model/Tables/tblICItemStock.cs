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
        public int? intLocationId { get; set; }
        public string strWarehouse { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblSuggestedQuantity { get; set; }
        public decimal? dblLeadTime { get; set; }
        public string strCounted { get; set; }
        public int? intInventoryGroupId { get; set; }
        public bool ysnCountedDaily { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICCountGroup tblICCountGroup { get; set; }
    }
}
