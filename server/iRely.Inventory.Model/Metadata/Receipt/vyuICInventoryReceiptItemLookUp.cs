using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryReceiptItemLookUp
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public string strOrderNumber { get; set; }
        public string strSourceNumber { get; set; }
        public DateTime? dtmDate { get; set; }
        public decimal? dblOrdered { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblReceived { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strSubLocationName { get; set; }
        public string strStorageLocationName { get; set; }
        public string strGrade { get; set; }
        public int? intCommodityId { get; set; }
        public string strWeightUOM { get; set; }
        public int? intWeightUOMId { get; set; }
        public int? intWeightUnitMeasureId { get; set; }
        public string strContainer { get; set; }
        public decimal? dblItemUOMConvFactor { get; set; }
        public decimal? dblWeightUOMConvFactor { get; set; }
        public decimal? dblGrossMargin { get; set; }
        public string strLifeTimeType { get; set; }
        public int? intLifeTime { get; set; }
        public string strCostUOM { get; set; }
        public decimal? dblCostUOMConvFactor { get; set; }
        public bool? ysnLoad { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public string strDiscountSchedule { get; set; }
        public decimal? dblFranchise { get; set; }
        public decimal? dblContainerWeightPerQty { get; set; }
        public string strSubCurrency { get; set; }
        public string strPricingType { get; set; }
        public string strTaxGroup { get; set; }
        public string strForexRateType { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intItemUOMDecimalPlaces { get; set; }
        public int? intContainerWeightUOMId { get; set; }
        public decimal? dblContainerWeightUOMConvFactor { get; set; }
        public bool? ysnLotWeightsRequired { get; set; }
        public int? intContractSeq { get; set; }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }
}
