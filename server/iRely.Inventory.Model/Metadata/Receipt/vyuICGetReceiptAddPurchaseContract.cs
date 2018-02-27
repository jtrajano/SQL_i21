using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetReceiptAddPurchaseContract
    {
        public int? intKey { get; set; }
        public int? intLocationId { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strReceiptType { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public decimal? dblOrdered { get; set; }
        public decimal? dblReceived { get; set; }
        public int? intSourceType { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public decimal? dblQtyToReceive { get; set; }
        public int? intLoadToReceive { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblLineTotal { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intContainerId { get; set; }
        public string strContainer { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intOrderUOMId { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblItemUOMConvFactor { get; set; }
        public decimal? dblWeightUOMConvFactor { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public decimal? dblCostUOMConvFactor { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public bool? ysnLoad { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public string strBOL { get; set; }
        public decimal? dblFranchise { get; set; }
        public decimal? dblContainerWeightPerQty { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public int intCurrencyId { get; set; }
        public string strSubCurrency { get; set; }
        public decimal? dblGross { get; set; }
        public decimal? dblNet { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public string strForexRateType { get; set; }
        //public bool? ysnBundleItem { get; set; }
        public string strBundleType { get; set; }
        //public int? intBundledItemId { get; set; }
        //public string strBundledItemNo { get; set; }
        //public string strBundledItemDescription { get; set; }
        //public bool? ysnIsBasket { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public int? intContractSeq { get; set; }
    }
}
