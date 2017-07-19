using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemPricing
    {
        public int intPricingKey { get; set; }
        public int intKey { get; set; }
        public string strItemNo { get; set; }
        public string strDescription { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strUpcCode { get; set; }
        public string strLongUPCCode { get; set; }
        public int? intItemPricingId { get; set; }
        public int? intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public bool? ysnStockUnit { get; set; }
        public bool? ysnAllowPurchase { get; set; }
        public bool? ysnAllowSale { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public int? intSort { get; set; }
        public int? intDecimalPlaces { get; set; }

        public vyuICGetItemStock vyuICGetItemStock { get; set; }
    }
}
