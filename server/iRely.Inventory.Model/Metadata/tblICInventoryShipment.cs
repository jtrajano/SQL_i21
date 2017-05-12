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
            this.tblICInventoryShipmentCharges = new List<tblICInventoryShipmentCharge>();
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
        public int? intCurrencyId { get; set; }
        public string strFreeTime { get; set; }
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
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intShipToCompanyLocationId { get; set; }

        //private string _shipFromAddress;
        //[NotMapped]
        //public string strShipFromAddress
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_shipFromAddress))
        //            if (vyuICGetInventoryShipment != null)
        //                return vyuICGetInventoryShipment.strShipFromAddress;
        //            else
        //                return null;
        //        else
        //            return _shipFromAddress;
        //    }
        //    set
        //    {
        //        _shipFromAddress = value;
        //    }

        //}
        private string _strShipFromStreet;
        [NotMapped]
        public string strShipFromStreet
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromStreet))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipFromStreet;
                    else
                        return null;
                else
                    return _strShipFromStreet;
            }
            set
            {
                _strShipFromStreet = value;
            }
        }

        private string _strShipFromCity;
        [NotMapped]
        public string strShipFromCity
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromCity))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipFromCity;
                    else
                        return null;
                else
                    return _strShipFromCity;
            }
            set
            {
                _strShipFromCity = value;
            }
        }

        private string _strShipFromState;
        [NotMapped]
        public string strShipFromState
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromState))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipFromState;
                    else
                        return null;
                else
                    return _strShipFromState;
            }
            set
            {
                _strShipFromState = value;
            }
        }

        private string _strShipFromZipPostalCode;
        [NotMapped]
        public string strShipFromZipPostalCode
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromZipPostalCode))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipFromZipPostalCode;
                    else
                        return null;
                else
                    return _strShipFromZipPostalCode;
            }
            set
            {
                _strShipFromZipPostalCode = value;
            }
        }

        private string _strShipFromCountry;
        [NotMapped]
        public string strShipFromCountry
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromCountry))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipFromCountry;
                    else
                        return null;
                else
                    return _strShipFromCountry;
            }
            set
            {
                _strShipFromCountry = value;
            }
        }

        //private string _shipToAddress;
        //[NotMapped]
        //public string strShipToAddress
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_shipToAddress))
        //            if (vyuICGetInventoryShipment != null)
        //                return vyuICGetInventoryShipment.strShipToAddress;
        //            else
        //                return null;
        //        else
        //            return _shipToAddress;
        //    }
        //    set
        //    {
        //        _shipToAddress = value;
        //    }
        //}

        private string _strShipToStreet;
        [NotMapped]
        public string strShipToStreet
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToStreet))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipToStreet;
                    else
                        return null;
                else
                    return _strShipToStreet;
            }
            set
            {
                _strShipToStreet = value;
            }
        }

        private string _strShipToCity;
        [NotMapped]
        public string strShipToCity
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToCity))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipToCity;
                    else
                        return null;
                else
                    return _strShipToCity;
            }
            set
            {
                _strShipToCity = value;
            }
        }

        private string _strShipToState;
        [NotMapped]
        public string strShipToState
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToState))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipToState;
                    else
                        return null;
                else
                    return _strShipToState;
            }
            set
            {
                _strShipToState = value;
            }
        }

        private string _strShipToZipPostalCode;
        [NotMapped]
        public string strShipToZipPostalCode
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToZipPostalCode))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipToZipPostalCode;
                    else
                        return null;
                else
                    return _strShipToZipPostalCode;
            }
            set
            {
                _strShipToZipPostalCode = value;
            }
        }

        private string _strShipToCountry;
        [NotMapped]
        public string strShipToCountry
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToCountry))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strShipToCountry;
                    else
                        return null;
                else
                    return _strShipToCountry;
            }
            set
            {
                _strShipToCountry = value;
            }
        }

        private string _custName;
        [NotMapped]
        public string strCustomerName
        {
            get
            {
                if (string.IsNullOrEmpty(_custName))
                    if (vyuICGetInventoryShipment != null)
                        return vyuICGetInventoryShipment.strCustomerName;
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
        private int? _warehouseId;
        [NotMapped]
        public int? intWarehouseInstructionHeaderId
        {
            get
            {
                if (vyuICGetInventoryShipment != null)
                    return vyuICGetInventoryShipment.intWarehouseInstructionHeaderId;
                else
                    return null;
            }
            set
            {
                _warehouseId = value;
            }
        }
        
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }
        public ICollection<tblICInventoryShipmentCharge> tblICInventoryShipmentCharges { get; set; }
        public vyuICGetInventoryShipment vyuICGetInventoryShipment { get; set; }
    }

    public class vyuICGetInventoryShipment
    {
        public int? intInventoryShipmentId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public string strOrderType { get; set; }
        public int? intSourceType { get; set; }
        public string strSourceType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public string strShipFromAddress { get; set; }
        public string strShipFromStreet { get; set; }
        public string strShipFromCity { get; set; }
        public string strShipFromState { get; set; }
        public string strShipFromZipPostalCode { get; set; }
        public string strShipFromCountry { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intShipToLocationId { get; set; }
        public string strShipToLocation { get; set; }
        public string strShipToAddress { get; set; }
        public string strShipToStreet { get; set; }
        public string strShipToCity { get; set; }
        public string strShipToState { get; set; }
        public string strShipToZipPostalCode { get; set; }
        public string strShipToCountry { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public string strFobPoint { get; set; }
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
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intWarehouseInstructionHeaderId { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }



        public tblICInventoryShipment tblICInventoryShipment { get; set; }
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
        public int? intStorageLocationId { get; set; }
        public int? intOwnershipType { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public int? intDockDoorId { get; set; }
        public string strNotes { get; set; }
        public int? intGradeId { get; set; }
        public int? intDiscountSchedule { get; set; }
        public int? intSort { get; set; }
        public int? intStorageScheduleTypeId  { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }

        private int? _decimalPlaces;
        [NotMapped]
        public int? intDecimalPlaces
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.intDecimalPlaces;
                else
                    return _decimalPlaces;
            }
            set
            {
                _decimalPlaces = value;
            }
        }

        private int? _unitMeasureId;
        [NotMapped]
        public int? intUnitMeasureId
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.intUnitMeasureId;
                else
                    return _unitMeasureId;
            }
            set
            {
                _unitMeasureId = value;
            }
        }

        private string _orderNumber;
        [NotMapped]
        public string strOrderNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_orderNumber))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strOrderNumber;
                    else
                        return null;
                else
                    return _orderNumber;
            }
            set
            {
                _orderNumber = value;
            }
        }
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
        private decimal _unitCost;
        [NotMapped]
        public decimal dblUnitCost
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblUnitCost ?? 0;
                else
                    return _unitCost;
            }
            set
            {
                _unitCost = value;
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
        private decimal _itemUOMConv;
        [NotMapped]
        public decimal dblItemUOMConv
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblItemUOMConv ?? 0;
                else
                    return _itemUOMConv;
            }
            set
            {
                _itemUOMConv = value;
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
        private decimal _weightItemUOMConv;
        [NotMapped]
        public decimal dblWeightItemUOMConv
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.dblWeightItemUOMConv ?? 0;
                else
                    return _weightItemUOMConv;
            }
            set
            {
                _weightItemUOMConv = value;
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
        private string _storageLocationName;
        [NotMapped]
        public string strStorageLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocationName))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strStorageLocationName;
                    else
                        return null;
                else
                    return _storageLocationName;
            }
            set
            {
                _storageLocationName = value;
            }
        }
        private string _ownershipType;
        [NotMapped]
        public string strOwnershipType
        {
            get
            {
                switch (intOwnershipType)
                {
                    case 1:
                        return "Own";
                    case 2:
                        return "Storage";
                    case 3:
                        return "Consigned Purchase";
                    case 4:
                        return "Consigned Sale";
                    default:
                        return "Own";
                }
            }
            set
            {
                _ownershipType = value;
            }
        }
        private string _grade;
        [NotMapped]
        public string strGrade
        {
            get
            {
                if (string.IsNullOrEmpty(_grade))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strGrade;
                    else
                        return null;
                else
                    return _grade;
            }
            set
            {
                _grade = value;
            }
        }
        private string _destinationWeights;
        [NotMapped]
        public string strDestinationWeights
        {
            get
            {
                if (string.IsNullOrEmpty(_destinationWeights))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strDestinationWeights;
                    else
                        return null;
                else
                    return _destinationWeights;
            }
            set
            {
                _destinationWeights = value;
            }
        }
        private string _destinationGrades;
        [NotMapped]
        public string strDestinationGrades
        {
            get
            {
                if (string.IsNullOrEmpty(_destinationGrades))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strDestinationGrades;
                    else
                        return null;
                else
                    return _destinationGrades;
            }
            set
            {
                _destinationGrades = value;
            }
        }

        private int? _commodityId;
        [NotMapped]
        public int? intCommodityId
        {
            get
            {
                if (vyuICGetInventoryShipmentItem != null)
                    return vyuICGetInventoryShipmentItem.intCommodityId;
                else
                    return _commodityId;
            }
            set
            {
                _commodityId = value;
            }
        }
        private string _discountSchedule;
        [NotMapped]
        public string strDiscountSchedule
        {
            get
            {
                if (string.IsNullOrEmpty(_discountSchedule))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strDiscountSchedule;
                    else
                        return null;
                else
                    return _discountSchedule;
            }
            set
            {
                _discountSchedule = value;
            }
        }
        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strCurrency;
                    else
                        return null;
                else
                    return _currency;
            }
            set
            {
                _currency = value;
            }
        }

        private string _storageTypeDescription; 
        [NotMapped]
        public string strStorageTypeDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_storageTypeDescription))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strStorageTypeDescription;
                    else
                        return null;
                else
                    return _storageTypeDescription;
            }
            set
            {
                _storageTypeDescription = value;
            }
        }

        private string _forexRateType;
        [NotMapped]
        public string strForexRateType
        {
            get
            {
                if (string.IsNullOrEmpty(_forexRateType))
                    if (vyuICGetInventoryShipmentItem != null)
                        return vyuICGetInventoryShipmentItem.strForexRateType;
                    else
                        return null;
                else
                    return _forexRateType;
            }
            set
            {
                _forexRateType = value;
            }
        }

        public vyuICGetInventoryShipmentItem vyuICGetInventoryShipmentItem { get; set; }
        public ICollection<tblICInventoryShipmentItemLot> tblICInventoryShipmentItemLots { get; set; }
        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        
    }

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
        public int? intDiscountSchedule { get; set; }
        public string strDiscountSchedule { get; set; }
        public string strStorageTypeDescription { get; set; }
        public string strForexRateType { get; set; }

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
    }

    public class tblICInventoryShipmentCharge : BaseEntity
    {
        public int intInventoryShipmentChargeId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public int? intContractId { get; set; }
        public int? intChargeId { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public int? intCurrencyId { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocatePriceBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public bool? ysnPrice { get; set; }
        public int? intSort { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }

        private string _contractNo;
        [NotMapped]
        public string strContractNumber
        {
            get
            {
                if (vyuICGetInventoryShipmentCharge != null)
                    return vyuICGetInventoryShipmentCharge.strContractNumber;
                else
                    return null;
            }
            set
            {
                _contractNo = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strItemNo;
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
        private string _itemDesc;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDesc))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strItemDescription;
                    else
                        return null;
                else
                    return _itemDesc;
            }
            set
            {
                _itemDesc = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strCostUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strCostUOM;
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
        private string _uomType;
        [NotMapped]
        public string strUnitType
        {
            get
            {
                if (string.IsNullOrEmpty(_uomType))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strUnitType;
                    else
                        return null;
                else
                    return _uomType;
            }
            set
            {
                _uomType = value;
            }
        }
        private string _onCostType;
        [NotMapped]
        public string strOnCostType
        {
            get
            {
                if (string.IsNullOrEmpty(_onCostType))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strOnCostType;
                    else
                        return null;
                else
                    return _onCostType;
            }
            set
            {
                _onCostType = value;
            }
        }
        private string _vendorId;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorId))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strVendorId;
                    else
                        return null;
                else
                    return _vendorId;
            }
            set
            {
                _vendorId = value;
            }
        }
        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strCurrency;
                    else
                        return null;
                else
                    return _currency;
            }
            set
            {
                _currency = value;
            }
        }
        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strVendorName;
                    else
                        return null;
                else
                    return _vendorName;
            }
            set
            {
                _vendorName = value;
            }
        }

        private string _forexRateType;
        [NotMapped]
        public string strForexRateType
        {
            get
            {
                if (string.IsNullOrEmpty(_forexRateType))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strForexRateType;
                    else
                        return null;
                else
                    return _forexRateType;
            }
            set
            {
                _forexRateType = value;
            }
        }

        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        public vyuICGetInventoryShipmentCharge vyuICGetInventoryShipmentCharge { get; set; }
    }

    public class vyuICGetInventoryShipmentCharge
    {
        public int intInventoryShipmentChargeId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public int? intContractId { get; set; }
        public string strContractNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public int? intOnCostTypeId { get; set; }
        public bool? ysnPrice { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocatePriceBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strForexRateType { get; set; }

        public tblICInventoryShipmentCharge tblICInventoryShipmentCharge { get; set; }
    }

    public class tblICInventoryShipmentItemLot : BaseEntity
    {

        public int intInventoryShipmentItemLotId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public int? intLotId { get; set; }
        public decimal? dblQuantityShipped { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblWeightPerQty { get; set; }
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
        private string _storageLoc;
        [NotMapped]
        public string strStorageLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLoc))
                    if (tblICLot != null)
                        return tblICLot.strStorageLocation;
                    else
                        return null;
                else
                    return _storageLoc;
            }
            set
            {
                _storageLoc = value;
            }
        }
        private decimal _lotQty;
        [NotMapped]
        public decimal dblLotQty
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblQty ?? 0;
                else
                    return _lotQty;
            }
            set
            {
                _lotQty = value;
            }
        }
        private decimal _lotUOMConv;
        [NotMapped]
        public decimal dblLotItemUOMConv
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblItemUOMConv ?? 0;
                else
                    return _lotUOMConv;
            }
            set
            {
                _lotUOMConv = value;
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
        //private decimal? _itemUOMConv;
        //[NotMapped]
        //public decimal? dblItemUOMConv
        //{
        //    get
        //    {
        //        if (tblICInventoryShipmentItem != null)
        //            return tblICLot.dblItemUOMConv;
        //        else
        //            return _itemUOMConv;
        //    }
        //    set
        //    {
        //        _itemUOMConv = value;
        //    }
        //}
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (tblICLot != null)
                        return tblICLot.strWeightUOM;
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
        private decimal? _weightConv;
        [NotMapped]
        public decimal? dblWeightItemUOMConv
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblWeightUOMConv;
                else
                    return _weightConv;
            }
            set
            {
                _weightConv = value;
            }
        }
        private decimal _availableQty;
        [NotMapped]
        public decimal dblAvailableQty
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblAvailableQty ?? 0;
                else
                    return _availableQty;
            }
            set
            {
                _availableQty = value;
            }
        }

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
        public tblICLot tblICLot { get; set; }

    }

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
        public string strUnitMeasure { get; set; }
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
        public string strStorageLocationName { get; set; }
        public decimal? dblLotQty { get; set; }
        public string strLotUOM { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblNetWeight { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
    }

    public class vyuICGetShipmentAddOrder
    {
        public int intKey { get; set; }
        public string strOrderType { get; set; }
        public string strSourceType { get; set; }
        public int? intLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intOrderUOMId { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblQtyShipped { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }
        public decimal? dblQtyToShip { get; set; }
        public decimal? dblPrice { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public int? strGrade { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public string strDestinationWeights { get; set; }
        public string strDestinationGrades { get; set; }
    }

    public class vyuICGetShipmentAddSalesContractPickLot
    {
        public int intKey { get; set; }
        public string strOrderType { get; set; }
        public string strSourceType { get; set; }
        public int? intLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intOrderUOMId { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblQtyShipped { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }
        public decimal? dblQtyToShip { get; set; }
        public decimal? dblPrice { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public int? strGrade { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public string strDestinationWeights { get; set; }
        public string strDestinationGrades { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public string strForexRateType { get; set; }
        public decimal? dblForexRate { get; set; }
    }

    public class vyuICGetShipmentAddSalesContract
    {
        public int intKey { get; set; }
        public string strOrderType { get; set; }
        public string strSourceType { get; set; }
        public int? intLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public int? strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intOrderUOMId { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblQtyShipped { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }
        public decimal? dblQtyToShip { get; set; }
        public decimal? dblPrice { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public int? strGrade { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public string strDestinationWeights { get; set; }
        public string strDestinationGrades { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public string strForexRateType { get; set; }
        public decimal? dblForexRate { get; set; }
    }

    public class vyuICGetShipmentAddSalesOrder
    {
        public int intKey { get; set; }
        public string strOrderType { get; set; }
        public string strSourceType { get; set; }
        public int? intLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public int? strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intOrderUOMId { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblQtyShipped { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }
        public decimal? dblQtyToShip { get; set; }
        public decimal? dblPrice { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public int? strGrade { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public string strDestinationWeights { get; set; }
        public string strDestinationGrades { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intFreightTermId { get; set; }
        public int? intShipToLocationId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public string strForexRateType { get; set; }
        public decimal? dblForexRate { get; set; }
    }

    public class vyuICShipmentInvoice
    {
        public int intInventoryShipmentId { get; set; }
        public int? intInventoryShipmentItemId { get; set; }
        public int? intInventoryShipmentChargeId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public string strCustomer { get; set; }
        public string strLocationName { get; set; }
        public string strDestination { get; set; }
        public string strBOLNumber { get; set; }
        public string strOrderType { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblShipmentQty { get; set; }
        public decimal? dblInTransitQty { get; set; }
        public decimal? dblInvoiceQty { get; set; }
        public decimal? dblShipmentLineTotal { get; set; }
        public decimal? dblInTransitTotal { get; set; }
        public decimal? dblInvoiceLineTotal { get; set; }
        public decimal? dblShipmentTax { get; set; }
        public decimal? dblInvoiceTax { get; set; }
        public decimal? dblOpenQty { get; set; }
        public decimal? dblItemsReceivable { get; set; }
        public decimal? dblTaxesReceivable { get; set; }
        public DateTime? dtmLastInvoiceDate { get; set; }
        public string strAllVouchers { get; set; }
        public string strFilterString { get; set; }
        public DateTime? dtmCreated { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strItemUOM { get; set; }
        public int? intItemUOMId { get; set; }
    }
}
