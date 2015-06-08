using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipment : BaseEntity
    {
        public tblICInventoryShipment()
        {
            this.tblICInventoryShipmentItems = new List<tblICInventoryShipmentItem>();
        }

        public int intInventoryShipmentId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public int? intSourceType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public int? intEntityCustomerId { get; set; }
        public int? intShipToLocationId { get; set; }
        public int? intFreightTermId { get; set; }
        public string strBOLNumber { get; set; }
        public int? intShipViaId { get; set; }
        public string strVessel { get; set; }
        public string strProNumber { get; set; }
        public string strDriverId { get; set; }
        public string strSealNumber { get; set; }
        public string strDeliveryInstruction { get; set; }
        public DateTime? dtmAppointmentTime { get; set; }
        public DateTime? dtmDepartureTime { get; set; }
        public DateTime? dtmArrivalTime { get; set; }
        public DateTime? dtmDeliveredDate { get; set; }
        public DateTime? dtmFreeTime { get; set; }
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public int? intCreatedUserId { get; set; }

        private string _shipFromAddress;
        [NotMapped]
        public string strShipFromAddress
        {
            get
            {
                if (string.IsNullOrEmpty(_shipFromAddress))
                    if (ShipFromLocation != null)
                        return ShipFromLocation.strAddress;
                    else
                        return null;
                else
                    return _shipFromAddress;
            }
            set
            {
                _shipFromAddress = value;
            }
        }
        private string _shipToAddress;
        [NotMapped]
        public string strShipToAddress
        {
            get
            {
                if (string.IsNullOrEmpty(_shipToAddress))
                    if (ShipToLocation != null)
                        return ShipToLocation.strAddress;
                    else
                        return null;
                else
                    return _shipToAddress;
            }
            set
            {
                _shipToAddress = value;
            }
        }
        private string _custName;
        [NotMapped]
        public string strCustomerName
        {
            get
            {
                if (string.IsNullOrEmpty(_custName))
                    if (tblARCustomer != null)
                        return tblARCustomer.strCustomerName;
                    else
                        return null;
                else
                    return _custName;
            }
            set
            {
                _custName = value;
            }
        }
        
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }
        public tblSMCompanyLocation ShipFromLocation { get; set; }
        public tblEntityLocation ShipToLocation { get; set; }
        public tblARCustomer tblARCustomer { get; set; } 
    }

    public class ShipmentVM
    {
        public int intInventoryShipmentId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public string strOrderType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerId { get; set; }
        public string strCustomerName { get; set; }
        public int? intShipToLocationId { get; set; }
        public string strShipToLocation { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public string strBOLNumber { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public string strVessel { get; set; }
        public string strProNumber { get; set; }
        public string strDriverId { get; set; }
        public string strSealNumber { get; set; }
        public string strDeliveryInstruction { get; set; }
        public DateTime? dtmAppointmentTime { get; set; }
        public DateTime? dtmDepartureTime { get; set; }
        public DateTime? dtmArrivalTime { get; set; }
        public DateTime? dtmDeliveredDate { get; set; }
        public DateTime? dtmFreeTime { get; set; }
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public bool? ysnPosted { get; set; }

    }

    public class tblICInventoryShipmentItem : BaseEntity
    {
        public tblICInventoryShipmentItem()
        {
            this.tblICInventoryShipmentItemLots = new List<tblICInventoryShipmentItemLot>();
        }

        public int intInventoryShipmentItemId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public int? intOrderId { get; set; }
        public int? intSourceId { get; set; }
        public int? intLineNo { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public int? intTaxCodeId { get; set; }
        public int? intDockDoorId { get; set; }
        public string strNotes { get; set; }
        public int? intSort { get; set; }

        private string _sourceNumber;
        [NotMapped]
        public string strSourceNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_sourceNumber))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strSourceNumber;
                    else
                        return null;
                else
                    return _sourceNumber;
            }
            set
            {
                _sourceNumber = value;
            }
        }
        private string _orderUOM;
        [NotMapped]
        public string strOrderUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_orderUOM))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strOrderUOM;
                    else
                        return null;
                else
                    return _orderUOM;
            }
            set
            {
                _orderUOM = value;
            }
        }
        private decimal _orderQty;
        [NotMapped]
        public decimal dblQtyOrdered
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblQtyOrdered ?? 0;
                else
                    return _orderQty;
            }
            set
            {
                _orderQty = value;
            }
        }
        private decimal _allocatedQty;
        [NotMapped]
        public decimal dblQtyAllocated
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblQtyAllocated ?? 0;
                else
                    return _allocatedQty;
            }
            set
            {
                _allocatedQty = value;
            }
        }
        private decimal _orderUnitPrice;
        [NotMapped]
        public decimal dblOrderUnitPrice
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblUnitPrice ?? 0;
                else
                    return _orderUnitPrice;
            }
            set
            {
                _orderUnitPrice = value;
            }
        }
        private decimal _orderDiscount;
        [NotMapped]
        public decimal dblOrderDiscount
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblDiscount ?? 0;
                else
                    return _orderDiscount;
            }
            set
            {
                _orderDiscount = value;
            }
        }
        private decimal _orderTotal;
        [NotMapped]
        public decimal dblOrderTotal
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblTotal ?? 0;
                else
                    return _orderTotal;
            }
            set
            {
                _orderTotal = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strItemNo;
                    else
                        return null;
                else
                    return _itemNo;
            }
            set
            {
                _itemNo = value;
            }
        }
        private string _description;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_description))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strItemDescription;
                    else
                        return null;
                else
                    return _description;
            }
            set
            {
                _description = value;
            }
        }
        private string _lotTracking;
        [NotMapped]
        public string strLotTracking
        {
            get
            {
                if (string.IsNullOrEmpty(_lotTracking))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strLotTracking;
                    else
                        return null;
                else
                    return _lotTracking;
            }
            set
            {
                _lotTracking = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strUnitMeasure;
                    else
                        return null;
                else
                    return _uom;
            }
            set
            {
                _uom = value;
            }
        }
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strWeightUOM;
                    else
                        return null;
                else
                    return _weightUOM;
            }
            set
            {
                _weightUOM = value;
            }
        }
        private string _subLocationName;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocationName))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocationName;
            }
            set
            {
                _subLocationName = value;
            }
        }

        public vyuICGetInventoryShipmentItem vyuICGetInventoryShipmentItem { get; set; }
        public ICollection<tblICInventoryShipmentItemLot> tblICInventoryShipmentItemLots { get; set; }
        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        
    }

    public class vyuICGetInventoryShipmentItem
    {
        public int intInventoryShipmentId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public string strOrderUOM { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
    }

    public class tblICInventoryShipmentItemLot : BaseEntity
    {

        public int intInventoryShipmentItemLotId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public int? intLotId { get; set; }
        public decimal? dblQuantityShipped { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public string strWarehouseCargoNumber { get; set; }
        public int? intSort { get; set; }
        
        private string _lotId;
        [NotMapped]
        public string strLotId
        {
            get
            {
                if (string.IsNullOrEmpty(_lotId))
                    if (tblICLot != null)
                        return tblICLot.strLotNumber;
                    else
                        return null;
                else
                    return _lotId;
            }
            set
            {
                _lotId = value;
            }
        }
        [NotMapped]
        public decimal dblLotQty
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblQty ?? 0;
                else
                    return 0;
            }
        }
        [NotMapped]
        public decimal dblLotItemUOMConv
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblItemUOMConv ?? 0;
                else
                    return 0;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICLot != null)
                        return tblICLot.strItemUOM;
                    else
                        return null;
                else
                    return _uom;
            }
            set
            {
                _uom = value;
            }
        }
        [NotMapped]
        public decimal dblItemUOMConv
        {
            get
            {
                if (tblICItemUOM != null)
                    return tblICItemUOM.dblUnitQty ?? 0;
                else
                    return 0;
            }
        }
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (tblICInventoryShipmentItem != null)
                        return tblICInventoryShipmentItem.strWeightUOM;
                    else
                        return null;
                else
                    return _weightUOM;
            }
            set
            {
                _weightUOM = value;
            }
        }
        [NotMapped]
        public decimal dblWeightItemUOMConv
        {
            get
            {
                if (WeightUOM != null)
                    return WeightUOM.dblUnitQty ?? 0;
                else
                    return 0;
            }
        }
        [NotMapped]
        public decimal dblAvailableQty
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblAvailableQty ?? 0;
                else
                    return 0;
            }
        }

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblICItemUOM WeightUOM { get; set; }
        public tblICLot tblICLot { get; set; }

    }
    
}
