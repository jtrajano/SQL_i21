using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICUnitMeasure : BaseEntity
    {
        public int intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strSymbol { get; set; }
        public string strUnitType { get; set; }
        public bool ysnDefault { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }
        public ICollection<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public ICollection<tblICItemUOM> tblICItemUOMs { get; set; }
        public ICollection<tblICUnitType> CapacityUnitTypes { get; set; }
        public ICollection<tblICUnitType> DimensionUnitTypes { get; set; }
        public ICollection<tblICItemManufacturingUOM> tblICItemManufacturingUOMs { get; set; }
        public ICollection<tblICRinFeedStockUOM> tblICRinFeedStockUOMs { get; set; }
        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemStock> tblICItemStocks { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
    }
}
