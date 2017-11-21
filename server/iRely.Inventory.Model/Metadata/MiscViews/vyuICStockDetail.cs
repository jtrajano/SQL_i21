using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICStockDetail
    {
        [Key]
        public int intKey { get; set; }

        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strLotTracking { get; set; }
        public string strInventoryTracking { get; set; }
        public string strStatus { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        //public string strStorageLocationName { get; set; }
        //public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intStockUOMId { get; set; }
        public string strStockUOM { get; set; }
        public string strStockUOMType { get; set; }
        public decimal? dblStockUnitQty { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public decimal? dblNearingReorderBy { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblInTransitInbound { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblInTransitOutbound { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblConsignedPurchase { get; set; }
        public decimal? dblConsignedSale { get; set; }
        public decimal? dblUnitReserved { get; set; }
        public decimal? dblAvailable { get; set; }
        public decimal? dblExtended { get; set; }
    }
}
