using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItem
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public string strReceiptNumber { get; set; }
        public string strReceiptType { get; set; }
        public string strLocationName { get; set; }
        public string strSourceType { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strBillOfLading { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public DateTime? dtmDate { get; set; }
        public decimal? dblOrdered { get; set; }
        public decimal? dblReceived { get; set; }
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
        public decimal? dblGrossWgt { get; set; }
        public decimal? dblNetWgt { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intContainerId { get; set; }
        public string strContainer { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblItemUOMConvFactor { get; set; }
        public decimal? dblWeightUOMConvFactor { get; set; }
        public string strCostUOM { get; set; }
        public decimal? dblCostUOMConvFactor { get; set; }
        public decimal? dblGrossMargin { get; set; }
        public int? intGradeId { get; set; }
        public decimal? dblBillQty { get; set; }
        public string strGrade { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public bool? ysnLoad { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public int? intDiscountSchedule { get; set; }
        public string strDiscountSchedule { get; set; }
        public bool? ysnExported { get; set; }
        public DateTime? dtmExportedDate { get; set; }
        public decimal? dblFranchise { get; set; }
        public decimal? dblContainerWeightPerQty { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public string strSubCurrency { get; set; }
        public string strVendorRefNo { get; set; }
        public string strShipFrom { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }
}
