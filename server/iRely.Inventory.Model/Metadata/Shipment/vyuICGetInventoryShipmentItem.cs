using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentItem
    {
        public int intInventoryShipmentId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public string strOrderType { get; set; }
        public string strSourceType { get; set; }
        public string strShipmentNumber { get; set; }
        public string strShipFromLocation { get; set; }
        public string strShipToLocation { get; set; }
        public string strBOLNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public string strOrderUOM { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intDecimalPlaces { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public string strUnitType { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }
        public decimal? dblQtyToShip { get; set; }
        public decimal? dblPrice { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public string strDestinationGrades { get; set; }
        public string strDestinationWeights { get; set; }
        public int? intDestinationWeightId { get; set; }
        public int? intDestinationGradeId { get; set; }
        // public decimal? dblDestinationGrossQty { get; set; }
        // public decimal? dblDestinationNetQty { get; set; }
        // public int? intDestinationQtyUOMId { get; set; }
        // public string strDestinationQtyUOM { get; set; }
        public int? intDiscountSchedule { get; set; }
        public string strDiscountSchedule { get; set; }
        public string strStorageTypeDescription { get; set; }
        public string strForexRateType { get; set; }
        public string strDockDoor { get; set; }
        public decimal? dblDestinationQuantity { get; set; }
        public int? intContractSeq { get; set; }
        public string strPriceUOM { get; set; }
        public decimal? dblCostUOMConv { get; set; }

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
    }
}
