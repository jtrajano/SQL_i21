using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStock
    {
        [Key]
        public int intKey { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strBundleType { get; set; }
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
        public string strStorageLocationName { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public int? intStockUOMId { get; set; }
        public string strStockUOM { get; set; }
        public string strStockUOMType { get; set; }
        public decimal? dblStockUnitQty { get; set; }
        public int? intReceiveUOMId { get; set; }
        public int? intReceiveUnitMeasureId { get; set; }
        public decimal? dblReceiveUOMConvFactor { get; set; }
        public int? intIssueUOMId { get; set; }
        public int? intGrossUOMId { get; set; }
        public int? intIssueUnitMeasureId { get; set; }
        public decimal? dblIssueUOMConvFactor { get; set; }
        public string strReceiveUOMType { get; set; }
        public string strIssueUOMType { get; set; }
        public string strReceiveUOM { get; set; }
        public string strGrossUOM { get; set; }
        public string strReceiveUPC { get; set; }
        public decimal? dblReceiveSalePrice { get; set; }
        public decimal? dblReceiveMSRPPrice { get; set; }
        public decimal? dblReceiveLastCost { get; set; }
        public decimal? dblReceiveStandardCost { get; set; }
        public decimal? dblReceiveAverageCost { get; set; }
        public decimal? dblReceiveEndMonthCost { get; set; }
        public bool? ysnReceiveUOMAllowPurchase { get; set; }
        public bool? ysnReceiveUOMAllowSale { get; set; }
        public string strIssueUOM { get; set; }
        public string strIssueUPC { get; set; }
        public decimal? dblIssueSalePrice { get; set; }
        public decimal? dblIssueMSRPPrice { get; set; }
        public decimal? dblIssueLastCost { get; set; }
        public decimal? dblIssueStandardCost { get; set; }
        public decimal? dblIssueAverageCost { get; set; }
        public decimal? dblIssueEndMonthCost { get; set; }
        public bool? ysnIssueUOMAllowPurchase { get; set; }
        public bool? ysnIssueUOMAllowSale { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblReorderPoint { get; set; }
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
        public decimal? dblLastCountRetail { get; set; }
        public decimal? dblAvailable { get; set; }
        //public decimal? dblStorageQty { get; set; }
        public decimal? dblDefaultFull { get; set; }
        public bool? ysnAvailableTM { get; set; }
        public decimal? dblMaintenanceRate { get; set; }
        public string strMaintenanceCalculationMethod { get; set; }
        public decimal? dblOverReceiveTolerance { get; set; }
        public decimal? dblWeightTolerance { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public bool? ysnListBundleSeparately { get; set; }
        public decimal? dblExtendedCost { get; set; }
        public string strRequired { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public string strTonnageTaxUOM { get; set; }
        public int? intModuleId { get; set; }
        public string strModule { get; set; }
        public bool? ysnUseWeighScales { get; set; }

        public int? intGrossUnitMeasureId { get; set; }
        public decimal? dblGrossUOMConvFactor { get; set; }
        public string strGrossUOMType { get; set; }
        public string strGrossUPC { get; set; }
        public decimal? dblGrossSalePrice { get; set; }
        public decimal? dblGrossMSRPPrice { get; set; }
        public decimal? dblGrossLastCost { get; set; }
        public decimal? dblGrossStandardCost { get; set; }
        public decimal? dblGrossAverageCost { get; set; }
        public decimal? dblGrossEndMonthCost { get; set; }
        public bool? ysnGrossUOMAllowPurchase { get; set; }
        public bool? ysnGrossUOMAllowSale { get; set; }
        public bool? ysnLotWeightsRequired { get; set; }


        public ICollection<vyuICGetItemPricing> tblICItemPricings { get; set; }
        public ICollection<vyuICGetItemAccount> tblICItemAccounts { get; set; }
        public tblICItem tblICItem { get; set; }
    }
}
