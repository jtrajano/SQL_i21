using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public int intDecimalDisplay { get; set; }
        public int intDecimalCalculation { get; set; }

        public ICollection<tblICUnitMeasureConversion> tblICUnitMeasureConversions { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }
        public ICollection<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public ICollection<tblICItemUOM> tblICItemUOMs { get; set; }
        public ICollection<tblICStorageUnitType> CapacityUnitTypes { get; set; }
        public ICollection<tblICStorageUnitType> DimensionUnitTypes { get; set; }
        public ICollection<tblICItemManufacturingUOM> tblICItemManufacturingUOMs { get; set; }
        public ICollection<tblICRinFeedStockUOM> tblICRinFeedStockUOMs { get; set; }
        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }

        public ICollection<tblICItemKitDetail> tblICItemKitDetails { get; set; }
        public ICollection<tblICItemAssembly> tblICItemAssemblies { get; set; }
        public ICollection<tblICItemBundle> tblICItemBundles { get; set; }

        public ICollection<tblICUnitMeasureConversion> StockUnitMeasureConversions { get; set; }
        public ICollection<tblICPackTypeDetail> SourcePackTypeDetails { get; set; }
        public ICollection<tblICPackTypeDetail> TargetPackTypeDetails { get; set; }

        public ICollection<tblICManufacturingCell> CapacityRateManufacturingCells { get; set; }
        public ICollection<tblICManufacturingCell> CapacityManufacturingCells { get; set; }

        public ICollection<tblICManufacturingCellPackType> CapacityRateManufacturingCellPackTypes { get; set; }
        public ICollection<tblICManufacturingCellPackType> CapacityManufacturingCellPackTypes { get; set; }

        public ICollection<tblICCertificationCommodity> tblICCertificationCommodities { get; set; }
        public ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }
        public ICollection<tblICInventoryShipmentItem> WeightInventoryShipmentItems { get; set; }
    }

    public class tblICUnitMeasureConversion : BaseEntity
    {
        public int intUnitMeasureConversionId { get; set; }
        public int intUnitMeasureId { get; set; }
        public int intStockUnitMeasureId { get; set; }
        public decimal? dblConversionToStock { get; set; }
        public decimal? dblConversionFromStock { get; set; }
        public int intSort { get; set; }

        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (StockUnitMeasure != null)
                        return StockUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _unitmeasure;
            }
            set
            {
                _unitmeasure = value;
            }
        }

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICUnitMeasure StockUnitMeasure { get; set; }
    }
}
