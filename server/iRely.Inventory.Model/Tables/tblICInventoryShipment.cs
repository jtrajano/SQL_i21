using System;
using System.Collections.Generic;
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
        public string strBOLNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public int? intShipToLocationId { get; set; }
        public int? intCustomerId { get; set; }
        public int? intFreightTermId { get; set; }
        public bool ysnDirectShipment { get; set; }
        public int? intCarrierId { get; set; }
        public string strVessel { get; set; }
        public string strProNumber { get; set; }
        public string strDriverId { get; set; }
        public string strSealNumber { get; set; }
        public DateTime? dtmAppointmentTime { get; set; }
        public DateTime? dtmDepartureTime { get; set; }
        public DateTime? dtmArrivalTime { get; set; }
        public DateTime? dtmDeliveredDate { get; set; }
        public DateTime? dtmFreeTime { get; set; }
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public string strDeliveryInstruction { get; set; }

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
        
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }
        public tblSMCompanyLocation ShipFromLocation { get; set; }
        public tblSMCompanyLocation ShipToLocation { get; set; }
        //public tblARCustomer tblARCustomer { get; set; } 
    }

    public class InventoryShipmentView
    {
        public int intInventoryShipmentId { get; set; }
        public string strBOLNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public string strOrderType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public int? intShipToLocationId { get; set; }
        public int? intCustomerId { get; set; }
        public string strCustomerId { get; set; }
        public string strShipToAddress { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTermId { get; set; }
        public bool ysnDirectShipment { get; set; }
        public int? intCarrierId { get; set; }
        public string strCarrierId { get; set; }
        public string strVessel { get; set; }
        public string strProNumber { get; set; }
        public string strDriverId { get; set; }
        public string strSealNumber { get; set; }
        public DateTime? dtmAppointmentTime { get; set; }
        public DateTime? dtmDepartureTime { get; set; }
        public DateTime? dtmArrivalTime { get; set; }
        public DateTime? dtmDeliveredDate { get; set; }
        public DateTime? dtmFreeTime { get; set; }
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public string strDeliveryInstruction { get; set; }

    }

    public class tblICInventoryShipmentItem : BaseEntity
    {
        public tblICInventoryShipmentItem()
        {
            this.tblICInventoryShipmentItemLots = new List<tblICInventoryShipmentItemLot>();
        }

        public int intInventoryShipmentItemId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public string strReferenceNumber { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intWeightUomId { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dbNetWeight { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public int? intDockDoorId { get; set; }
        public string strNotes { get; set; }
        public int? intSort { get; set; }

        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (tblICItem != null)
                        return tblICItem.strItemNo;
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
                    if (tblICItem != null)
                        return tblICItem.strDescription;
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
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
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
        private string _weightUom;
        [NotMapped]
        public string strWeightUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUom))
                    if (WeightUnitMeasure != null)
                        return WeightUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _weightUom;
            }
            set
            {
                _weightUom = value;
            }
        }

        public ICollection<tblICInventoryShipmentItemLot> tblICInventoryShipmentItemLots { get; set; }
        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        public tblICItem tblICItem { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICUnitMeasure WeightUnitMeasure { get; set; }
    }

    public class tblICInventoryShipmentItemLot : BaseEntity
    {

        public int intInventoryShipmentItemLotId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public int? intLotId { get; set; }
        public decimal? dblQuantityShipped { get; set; }
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
                        return tblICLot.strLotId;
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

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
        public tblICLot tblICLot { get; set; }

    }

}
