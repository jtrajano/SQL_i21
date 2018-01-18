using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICSearchItem
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strManufacturer { get; set; }
        public string strBrandCode { get; set; }
        public string strBrandName { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strTracking { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public bool? ysnAccrue { get; set; }
        public bool? ysnMTM { get; set; }
        public int? intM2MComputationId { get; set; }
        public string strM2MComputation { get; set; }
        public bool? ysnPrice { get; set; }
        public string strCostMethod { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public string strCostType { get; set; }
        public string strShortName { get; set; }
        public string strRequired { get; set; }
        public bool? ysnBasisContract { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public string strTonnageTaxUOM { get; set; }
        // Begin Commodity Tab fields
        public decimal? dblGAShrinkFactor { get; set; }
        public int? intOriginId { get; set; }
        public string strOrigin { get; set; }
        public int? intProductTypeId { get; set; }
        public string strProductType { get; set; }
        public int? intRegionId { get; set; }
        public string strRegion { get; set; }
        public int? intSeasonId { get; set; }
        public string strSeason { get; set; }
        public int? intClassVarietyId { get; set; }
        public string strClass { get; set; }
        public int? intProductLineId { get; set; }
        public string strProductLine { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public string strMarketValuation { get; set; }
        // End Commodity Tab fields
        public string strBundleType { get; set; }
        public bool? ysnListBundleSeparately { get; set; }
    }
}
