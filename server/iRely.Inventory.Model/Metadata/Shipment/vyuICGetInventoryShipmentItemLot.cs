using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentItemLot
    {
        public int intInventoryShipmentId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public int intInventoryShipmentItemLotId { get; set; }
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
        public string strOrderUOM { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public string strUnitType { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
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
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocation { get; set; }
        public decimal? dblQuantityShipped { get; set; }
        public string strLotUOM { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblNetWeight { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public string strWarehouseCargoNumber { get; set;  }
    }
}
