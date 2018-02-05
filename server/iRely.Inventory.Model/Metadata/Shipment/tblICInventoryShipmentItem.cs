using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
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
        public int? intStorageScheduleTypeId { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public decimal? dblDestinationQuantity { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public string strChargesLink { get; set; }
        //private int? _decimalPlaces;
        //[NotMapped]
        //public int? intDecimalPlaces
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.intDecimalPlaces;
        //        else
        //            return _decimalPlaces;
        //    }
        //    set
        //    {
        //        _decimalPlaces = value;
        //    }
        //}

        //private int? _unitMeasureId;
        //[NotMapped]
        //public int? intUnitMeasureId
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.intUnitMeasureId;
        //        else
        //            return _unitMeasureId;
        //    }
        //    set
        //    {
        //        _unitMeasureId = value;
        //    }
        //}

        //private string _orderNumber;
        //[NotMapped]
        //public string strOrderNumber
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_orderNumber))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strOrderNumber;
        //            else
        //                return null;
        //        else
        //            return _orderNumber;
        //    }
        //    set
        //    {
        //        _orderNumber = value;
        //    }
        //}
        //private string _sourceNumber;
        //[NotMapped]
        //public string strSourceNumber
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_sourceNumber))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strSourceNumber;
        //            else
        //                return null;
        //        else
        //            return _sourceNumber;
        //    }
        //    set
        //    {
        //        _sourceNumber = value;
        //    }
        //}
        //private string _orderUOM;
        //[NotMapped]
        //public string strOrderUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_orderUOM))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strOrderUOM;
        //            else
        //                return null;
        //        else
        //            return _orderUOM;
        //    }
        //    set
        //    {
        //        _orderUOM = value;
        //    }
        //}
        //private decimal _orderQty;
        //[NotMapped]
        //public decimal dblQtyOrdered
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblQtyOrdered ?? 0;
        //        else
        //            return _orderQty;
        //    }
        //    set
        //    {
        //        _orderQty = value;
        //    }
        //}
        //private decimal _allocatedQty;
        //[NotMapped]
        //public decimal dblQtyAllocated
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblQtyAllocated ?? 0;
        //        else
        //            return _allocatedQty;
        //    }
        //    set
        //    {
        //        _allocatedQty = value;
        //    }
        //}
        //private decimal _orderUnitPrice;
        //[NotMapped]
        //public decimal dblOrderUnitPrice
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblUnitPrice ?? 0;
        //        else
        //            return _orderUnitPrice;
        //    }
        //    set
        //    {
        //        _orderUnitPrice = value;
        //    }
        //}
        //private decimal _orderDiscount;
        //[NotMapped]
        //public decimal dblOrderDiscount
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblDiscount ?? 0;
        //        else
        //            return _orderDiscount;
        //    }
        //    set
        //    {
        //        _orderDiscount = value;
        //    }
        //}
        //private decimal _orderTotal;
        //[NotMapped]
        //public decimal dblOrderTotal
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblTotal ?? 0;
        //        else
        //            return _orderTotal;
        //    }
        //    set
        //    {
        //        _orderTotal = value;
        //    }
        //}
        //private decimal _unitCost;
        //[NotMapped]
        //public decimal dblUnitCost
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblUnitCost ?? 0;
        //        else
        //            return _unitCost;
        //    }
        //    set
        //    {
        //        _unitCost = value;
        //    }
        //}
        //private string _itemNo;
        //[NotMapped]
        //public string strItemNo
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_itemNo))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strItemNo;
        //            else
        //                return null;
        //        else
        //            return _itemNo;
        //    }
        //    set
        //    {
        //        _itemNo = value;
        //    }
        //}
        //private string _description;
        //[NotMapped]
        //public string strItemDescription
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_description))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strItemDescription;
        //            else
        //                return null;
        //        else
        //            return _description;
        //    }
        //    set
        //    {
        //        _description = value;
        //    }
        //}
        //private string _lotTracking;
        //[NotMapped]
        //public string strLotTracking
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_lotTracking))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strLotTracking;
        //            else
        //                return null;
        //        else
        //            return _lotTracking;
        //    }
        //    set
        //    {
        //        _lotTracking = value;
        //    }
        //}
        //private string _uom;
        //[NotMapped]
        //public string strUnitMeasure
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_uom))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strUnitMeasure;
        //            else
        //                return null;
        //        else
        //            return _uom;
        //    }
        //    set
        //    {
        //        _uom = value;
        //    }
        //}
        //private decimal _itemUOMConv;
        //[NotMapped]
        //public decimal dblItemUOMConv
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblItemUOMConv ?? 0;
        //        else
        //            return _itemUOMConv;
        //    }
        //    set
        //    {
        //        _itemUOMConv = value;
        //    }
        //}
        //private string _weightUOM;
        //[NotMapped]
        //public string strWeightUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_weightUOM))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strWeightUOM;
        //            else
        //                return null;
        //        else
        //            return _weightUOM;
        //    }
        //    set
        //    {
        //        _weightUOM = value;
        //    }
        //}
        //private decimal _weightItemUOMConv;
        //[NotMapped]
        //public decimal dblWeightItemUOMConv
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.dblWeightItemUOMConv ?? 0;
        //        else
        //            return _weightItemUOMConv;
        //    }
        //    set
        //    {
        //        _weightItemUOMConv = value;
        //    }
        //}
        //private string _subLocationName;
        //[NotMapped]
        //public string strSubLocationName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_subLocationName))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strSubLocationName;
        //            else
        //                return null;
        //        else
        //            return _subLocationName;
        //    }
        //    set
        //    {
        //        _subLocationName = value;
        //    }
        //}
        //private string _storageLocationName;
        //[NotMapped]
        //public string strStorageLocationName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_storageLocationName))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strStorageLocationName;
        //            else
        //                return null;
        //        else
        //            return _storageLocationName;
        //    }
        //    set
        //    {
        //        _storageLocationName = value;
        //    }
        //}
        //private string _dockDoor;
        //[NotMapped]
        //public string strDockDoor
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_dockDoor))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strDockDoor;
        //            else
        //                return null;
        //        else
        //            return _dockDoor;
        //    }
        //    set
        //    {
        //        _dockDoor = value;
        //    }
        //}
        //private string _ownershipType;
        //[NotMapped]
        //public string strOwnershipType
        //{
        //    get
        //    {
        //        switch (intOwnershipType)
        //        {
        //            case 1:
        //                return "Own";
        //            case 2:
        //                return "Storage";
        //            case 3:
        //                return "Consigned Purchase";
        //            case 4:
        //                return "Consigned Sale";
        //            default:
        //                return "Own";
        //        }
        //    }
        //    set
        //    {
        //        _ownershipType = value;
        //    }
        //}
        //private string _grade;
        //[NotMapped]
        //public string strGrade
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_grade))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strGrade;
        //            else
        //                return null;
        //        else
        //            return _grade;
        //    }
        //    set
        //    {
        //        _grade = value;
        //    }
        //}
        //private string _destinationWeights;
        //[NotMapped]
        //public string strDestinationWeights
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_destinationWeights))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strDestinationWeights;
        //            else
        //                return null;
        //        else
        //            return _destinationWeights;
        //    }
        //    set
        //    {
        //        _destinationWeights = value;
        //    }
        //}
        //private string _destinationGrades;
        //[NotMapped]
        //public string strDestinationGrades
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_destinationGrades))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strDestinationGrades;
        //            else
        //                return null;
        //        else
        //            return _destinationGrades;
        //    }
        //    set
        //    {
        //        _destinationGrades = value;
        //    }
        //}

        //private int? _commodityId;
        //[NotMapped]
        //public int? intCommodityId
        //{
        //    get
        //    {
        //        if (vyuICGetInventoryShipmentItem != null)
        //            return vyuICGetInventoryShipmentItem.intCommodityId;
        //        else
        //            return _commodityId;
        //    }
        //    set
        //    {
        //        _commodityId = value;
        //    }
        //}
        //private string _discountSchedule;
        //[NotMapped]
        //public string strDiscountSchedule
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_discountSchedule))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strDiscountSchedule;
        //            else
        //                return null;
        //        else
        //            return _discountSchedule;
        //    }
        //    set
        //    {
        //        _discountSchedule = value;
        //    }
        //}
        //private string _currency;
        //[NotMapped]
        //public string strCurrency
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_currency))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strCurrency;
        //            else
        //                return null;
        //        else
        //            return _currency;
        //    }
        //    set
        //    {
        //        _currency = value;
        //    }
        //}

        //private string _storageTypeDescription;
        //[NotMapped]
        //public string strStorageTypeDescription
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_storageTypeDescription))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strStorageTypeDescription;
        //            else
        //                return null;
        //        else
        //            return _storageTypeDescription;
        //    }
        //    set
        //    {
        //        _storageTypeDescription = value;
        //    }
        //}

        //private string _forexRateType;
        //[NotMapped]
        //public string strForexRateType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_forexRateType))
        //            if (vyuICGetInventoryShipmentItem != null)
        //                return vyuICGetInventoryShipmentItem.strForexRateType;
        //            else
        //                return null;
        //        else
        //            return _forexRateType;
        //    }
        //    set
        //    {
        //        _forexRateType = value;
        //    }
        //}
        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        public vyuICGetInventoryShipmentItem vyuICGetInventoryShipmentItem { get; set; }
        public ICollection<tblICInventoryShipmentItemLot> tblICInventoryShipmentItemLots { get; set; }

    }
}
