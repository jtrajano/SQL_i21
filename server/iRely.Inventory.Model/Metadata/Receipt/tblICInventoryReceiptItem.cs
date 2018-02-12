using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptItem : BaseEntity
    {
        public tblICInventoryReceiptItem()
        {
            this.tblICInventoryReceiptItemLots = new List<tblICInventoryReceiptItemLot>();
            this.tblICInventoryReceiptItemTaxes = new List<tblICInventoryReceiptItemTax>();
        }

        public int intInventoryReceiptItemId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public int? intSourceId { get; set; }
        public int? intItemId { get; set; }
        public int? intContainerId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intOwnershipType { get; set; }
        public decimal? dblOrderQty { get; set; }
        public decimal? dblBillQty { get; set; }
        public decimal? dblOpenReceive { get; set; }
        public int? intLoadReceive { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intWeightUOMId { get; set; }
        public int? intCostUOMId { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblUnitRetail { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public decimal? dblGross { get; set; }
        public decimal? dblNet { get; set; }
        public decimal? dblTax { get; set; }
        public int? intDiscountSchedule { get; set; }
        public bool? ysnExported { get; set; }
        public DateTime? dtmExportedDate { get; set; }
        public int? intSort { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public decimal? dblForexRate { get; set; }
        public bool? ysnLotWeightsRequired { get; set; }
        public string strChargesLink { get; set; }
        public string strItemType { get; set; }

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

        //private string _orderNumber;
        //[NotMapped]
        //public string strOrderNumber
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_orderNumber))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strOrderNumber;
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
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strSourceNumber;
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
        //private DateTime? _orderDate = null;
        //[NotMapped]
        //public DateTime? dtmOrderDate
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dtmDate;
        //        else
        //            return _orderDate;
        //    }
        //    set
        //    {
        //        _orderDate = value;
        //    }
        //}
        //private string _itemNo;
        //[NotMapped]
        //public string strItemNo
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_itemNo))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strItemNo;
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
        //private string _itemDescription;
        //[NotMapped]
        //public string strItemDescription
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_itemDescription))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strItemDescription;
        //            else
        //                return null;
        //        else
        //            return _itemDescription;
        //    }
        //    set
        //    {
        //        _itemDescription = value;
        //    }
        //}
        //private string _lotTracking;
        //[NotMapped]
        //public string strLotTracking
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_lotTracking))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strLotTracking;
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
        //private string _orderUOM;
        //[NotMapped]
        //public string strOrderUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_orderUOM))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strOrderUOM;
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
        //private decimal _orderedQty;
        //[NotMapped]
        //public decimal dblOrdered
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblOrdered ?? 0;
        //        else
        //            return _orderedQty;
        //    }
        //    set
        //    {
        //        _orderedQty = value;
        //    }
        //}
        //private decimal _receivedQty;
        //[NotMapped]
        //public decimal dblReceived
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblReceived ?? 0;
        //        else
        //            return _receivedQty;
        //    }
        //    set
        //    {
        //        _receivedQty = value;
        //    }
        //}
        //private decimal _orderConvFactor;
        //[NotMapped]
        //public decimal dblOrderUOMConvFactor
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblOrderUOMConvFactor ?? 0;
        //        else
        //            return _orderConvFactor;
        //    }
        //    set
        //    {
        //        _orderConvFactor = value;
        //    }
        //}
        //private string _uom;
        //[NotMapped]
        //public string strUnitMeasure
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_uom))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strUnitMeasure;
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

        //private int? _uomId;
        //[NotMapped]
        //public int? intItemUOMId
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.intItemUOMId;
        //        return null;
        //    }
        //    set
        //    {
        //        this._uomId = value;
        //    }
        //}

        //private int? _uomDecimals;
        //[NotMapped]
        //public int? intItemUOMDecimalPlaces
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.intItemUOMDecimalPlaces;
        //        return null;
        //    }
        //    set
        //    {
        //        this._uomDecimals = value;
        //    }
        //}

        //private string _uomType;
        //[NotMapped]
        //public string strUnitType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_uomType))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strUnitType;
        //            else
        //                return null;
        //        else
        //            return _uomType;
        //    }
        //    set
        //    {
        //        _uomType = value;
        //    }
        //}
        //private string _subLocationName;
        //[NotMapped]
        //public string strSubLocationName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_subLocationName))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strSubLocationName;
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
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strStorageLocationName;
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
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strGrade;
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
        //private int? _commodityId;
        //[NotMapped]
        //public int? intCommodityId
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.intCommodityId;
        //        else
        //            return null;
        //    }
        //    set
        //    {
        //        _commodityId = value;
        //    }
        //}
        //private string _weigthUOM;
        //[NotMapped]
        //public string strWeightUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_weigthUOM))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strWeightUOM;
        //            else
        //                return null;
        //        else
        //            return _weigthUOM;
        //    }
        //    set
        //    {
        //        _weigthUOM = value;
        //    }
        //}
        //private string _container;
        //[NotMapped]
        //public string strContainer
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_container))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strContainer;
        //            else
        //                return null;
        //        else
        //            return _container;
        //    }
        //    set
        //    {
        //        _container = value;
        //    }
        //}
        //private decimal _itemConv;
        //[NotMapped]
        //public decimal dblItemUOMConvFactor
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblItemUOMConvFactor ?? 0;
        //        else
        //            return _itemConv;
        //    }
        //    set
        //    {
        //        _itemConv = value;
        //    }
        //}
        //private decimal _weightConv;
        //[NotMapped]
        //public decimal dblWeightUOMConvFactor
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblWeightUOMConvFactor ?? 0;
        //        else
        //            return _weightConv;
        //    }
        //    set
        //    {
        //        _weightConv = value;
        //    }
        //}
        //private decimal _grossMargin;
        //[NotMapped]
        //public decimal dblGrossMargin
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblGrossMargin ?? 0;
        //        else
        //            return _grossMargin;
        //    }
        //    set
        //    {
        //        _grossMargin = value;
        //    }
        //}
        //private string _lifetimeType;
        //[NotMapped]
        //public string strLifeTimeType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_lifetimeType))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strLifeTimeType;
        //            else
        //                return null;
        //        else
        //            return _lifetimeType;
        //    }
        //    set
        //    {
        //        _lifetimeType = value;
        //    }
        //}
        //private int _lifetime;
        //[NotMapped]
        //public int intLifeTime
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.intLifeTime ?? 0;
        //        else
        //            return _lifetime;
        //    }
        //    set
        //    {
        //        _lifetime = value;
        //    }
        //}
        //private string _costUOM;
        //[NotMapped]
        //public string strCostUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_costUOM))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strCostUOM;
        //            else
        //                return null;
        //        else
        //            return _costUOM;
        //    }
        //    set
        //    {
        //        _costUOM = value;
        //    }
        //}
        //private decimal _costCF;
        //[NotMapped]
        //public decimal dblCostUOMConvFactor
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblCostUOMConvFactor ?? 0;
        //        else
        //            return _costCF;
        //    }
        //    set
        //    {
        //        _costCF = value;
        //    }
        //}
        //private bool _loadContract;
        //[NotMapped]
        //public bool ysnLoad
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.ysnLoad ?? false;
        //        else
        //            return _loadContract;
        //    }
        //    set
        //    {
        //        _loadContract = value;
        //    }
        //}
        //private decimal _availableQty;
        //[NotMapped]
        //public decimal dblAvailableQty
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblAvailableQty ?? 0;
        //        else
        //            return _availableQty;
        //    }
        //    set
        //    {
        //        _availableQty = value;
        //    }
        //}
        //private string _discountSchedule;
        //[NotMapped]
        //public string strDiscountSchedule
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_discountSchedule))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strDiscountSchedule;
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
        //private decimal _franchise;
        //[NotMapped]
        //public decimal dblFranchise
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblFranchise ?? 0;
        //        else
        //            return _franchise;
        //    }
        //    set
        //    {
        //        _franchise = value;
        //    }
        //}
        //private decimal _containerWeightPerQty;
        //[NotMapped]
        //public decimal dblContainerWeightPerQty
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptItemLookUp != null)
        //            return vyuICInventoryReceiptItemLookUp.dblContainerWeightPerQty ?? 0;
        //        else
        //            return _containerWeightPerQty;
        //    }
        //    set
        //    {
        //        _containerWeightPerQty = value;
        //    }
        //}
        //private string _subSubCurrency;
        //[NotMapped]
        //public string strSubCurrency
        //{
        //    get
        //    {                               
        //        if (string.IsNullOrEmpty(_subSubCurrency))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strSubCurrency;
        //            else
        //                return null;
        //        else
        //            return _subSubCurrency;
        //    }
        //    set
        //    {
        //        _subSubCurrency = value;
        //    }
        //}
        //private string _pricingType;
        //[NotMapped]
        //public string strPricingType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_pricingType))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strPricingType;
        //            else
        //                return null;
        //        else
        //            return _pricingType;
        //    }
        //    set
        //    {
        //        _pricingType = value;
        //    }
        //}
        //private string _itemTaxGroup;
        //[NotMapped]
        //public string strTaxGroup
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_itemTaxGroup))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strTaxGroup;
        //            else
        //                return null;
        //        else
        //            return _itemTaxGroup;
        //    }
        //    set
        //    {
        //        _itemTaxGroup = value;
        //    }
        //}
        //private string _forexRateType; 
        //[NotMapped]
        //public string strForexRateType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_forexRateType))
        //            if (vyuICInventoryReceiptItemLookUp != null)
        //                return vyuICInventoryReceiptItemLookUp.strForexRateType;
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

        /* private decimal _franchise;
         [NotMapped]
         public decimal dblFranchise
         {
             get
             {
                 if (vyuICGetInventoryReceiptItem != null)
                     return vyuICGetInventoryReceiptItem.dblFranchise ?? 0;
                 else
                     return _franchise;
             }
             set
             {
                 _franchise = value;
             }
         }
         private decimal _containerWeightPerQty;
         [NotMapped]
         public decimal dblContainerWeightPerQty
         {
             get
             {
                 if (vyuICGetInventoryReceiptItem != null)
                     return vyuICGetInventoryReceiptItem.dblContainerWeightPerQty ?? 0;
                 else
                     return _containerWeightPerQty;
             }
             set
             {
                 _containerWeightPerQty = value;
             }
         }*/

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public tblICItem tblICItem { get; set; }

        public vyuICInventoryReceiptItemLookUp vyuICInventoryReceiptItemLookUp { get; set; }
        public ICollection<tblICInventoryReceiptItemLot> tblICInventoryReceiptItemLots { get; set; }
        public ICollection<tblICInventoryReceiptItemTax> tblICInventoryReceiptItemTaxes { get; set; }
    }
}
