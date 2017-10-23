using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemCommodity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strLotTracking { get; set; }
        public int? intBrandId { get; set; }
        public string strBrand { get; set; }
        public int? intManufacturerId { get; set; }
        public string strManufacturer { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intLocationId { get; set; }
        public string strTracking { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public int? intOriginId { get; set; }
        public string strOrigin { get; set; }
        public int? intProductTypeId { get; set; }
        public string strProductType { get; set; }
        public int? intRegionId { get; set; }
        public string strRegion { get; set; }
        public int? intSeasonId { get; set; }
        public string strSeason { get; set; }
        public int? intClassVarietyId { get; set; }
        public string strClassVariety { get; set; }
        public int? intProductLineId { get; set; }
        public string strProductLine { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public int? intAdjustInventorySales { get; set; }
        public string strAdjustInventorySales { get; set; }
        public int? intAdjustInventoryTransfer { get; set; }
        public string strAdjustInventoryTransfer { get; set; }
    }
}
