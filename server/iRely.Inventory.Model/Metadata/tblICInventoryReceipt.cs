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
    public class tblICInventoryReceipt : BaseEntity
    {
        public tblICInventoryReceipt()
        {
            this.tblICInventoryReceiptInspections = new List<tblICInventoryReceiptInspection>();
            this.tblICInventoryReceiptItems = new List<tblICInventoryReceiptItem>();
            this.tblICInventoryReceiptCharges = new List<tblICInventoryReceiptCharge>();
        }

        public int intInventoryReceiptId { get; set; }
        public string strReceiptType { get; set; }
        public int? intSourceType { get; set; }
        public int? intEntityVendorId { get; set; }
        public int? intTransferorId { get; set; }
        public int? intLocationId { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intSubCurrencyCents { get; set; }
        public int? intBlanketRelease { get; set; }
        public string strVendorRefNo { get; set; }
        public string strBillOfLading { get; set; }
        public int? intShipViaId { get; set; }
        public int? intShipFromId { get; set; }
        public int? intReceiverId { get; set; }
        public string strVessel { get; set; }
        public int? intFreightTermId { get; set; }
        public int? intShiftNumber { get; set; }
        public decimal? dblInvoiceAmount { get; set; }
        public bool? ysnPrepaid { get; set; }
        public bool? ysnInvoicePaid { get; set; }
        public int? intCheckNo { get; set; }
        public DateTime? dtmCheckDate { get; set; }
        public int? intTrailerTypeId { get; set; }
        public DateTime? dtmTrailerArrivalDate { get; set; }
        public DateTime? dtmTrailerArrivalTime { get; set; }
        public string strSealNo { get; set; }
        public string strSealStatus { get; set; }
        public DateTime? dtmReceiveTime { get; set; }
        public decimal? dblActualTempReading { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intShipmentId { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intEntityId { get; set; }
        public bool? ysnOrigin { get; set; }
        public string strWarehouseRefNo { get; set; }
        public DateTime? dtmLastFreeWhseDate { get; set; }

        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strVendorName;
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
        private int? _vendorEntity;
        [NotMapped]
        public int? intVendorEntityId
        {
            get
            {
                if (vyuICInventoryReceiptLookUp != null)
                    return vyuICInventoryReceiptLookUp.intEntityId;
                else
                    return -1;
            }
            set
            {
                _vendorEntity = value;
            }
        }
        private string _fobPoint;
        [NotMapped]
        public string strFobPoint
        {
            get
            {
                if (string.IsNullOrEmpty(_fobPoint))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strFobPoint;
                    else
                        return null;
                else
                    return _fobPoint;
            }
            set
            {
                _fobPoint = value;
            }
        }
        private string _locationName;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_locationName))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strLocationName;
                    else
                        return null;
                else
                    return _locationName;
            }
            set
            {
                _locationName = value;
            }
        }
        private string _currencyName;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currencyName))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strCurrency;
                    else
                        return null;
                else
                    return _currencyName;
            }
            set
            {
                _currencyName = value;
            }
        }
        private string _fromLocation;
        [NotMapped]
        public string strFromLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_fromLocation))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strFromLocation;
                    else
                        return null;
                else
                    return _fromLocation;
            }
            set
            {
                _fromLocation = value;
            }
        }
        private string _receiver;
        [NotMapped]
        public string strUserName
        {
            get
            {
                if (string.IsNullOrEmpty(_receiver))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strUserName;
                    else
                        return null;
                else
                    return _receiver;
            }
            set
            {
                _receiver = value;
            }
        }
        private string _shipFrom;
        [NotMapped]
        public string strShipFrom
        {
            get
            {
                if (string.IsNullOrEmpty(_shipFrom))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strShipFrom;
                    else
                        return null;
                else
                    return _shipFrom;
            }
            set
            {
                _shipFrom = value;
            }
        }
        private string _shipVia;
        [NotMapped]
        public string strShipVia
        {
            get
            {
                if (string.IsNullOrEmpty(_shipVia))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strShipVia;
                    else
                        return null;
                else
                    return _shipVia;
            }
            set
            {
                _shipVia = value;
            }
        }
        private string _freightTerm;
        [NotMapped]
        public string strFreightTerm
        {
            get
            {
                if (string.IsNullOrEmpty(_freightTerm))
                    if (vyuICInventoryReceiptLookUp != null)
                        return vyuICInventoryReceiptLookUp.strFreightTerm;
                    else
                        return null;
                else
                    return _freightTerm;
            }
            set
            {
                _freightTerm = value;
            }
        }
        public ICollection<tblICInventoryReceiptInspection> tblICInventoryReceiptInspections { get; set; }
        public ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
        public ICollection<tblICInventoryReceiptCharge> tblICInventoryReceiptCharges { get; set; }

        public vyuICInventoryReceiptLookUp vyuICInventoryReceiptLookUp { get; set; }
    }

    public class vyuICGetInventoryReceipt
    {
        public int intInventoryReceiptId { get; set; }
        public string strReceiptType { get; set; }
        public int? intSourceType { get; set; }
        public string strSourceType { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public int? intTransferorId { get; set; }
        public string strTransferor { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public int? intSubCurrencyCents { get; set; }
        public int? intBlanketRelease { get; set; }
        public string strVendorRefNo { get; set; }
        public string strBillOfLading { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public int? intShipFromId { get; set; }
        public string strShipFrom { get; set; }
        public int? intReceiverId { get; set; }
        public string strReceiver { get; set; }
        public string strVessel { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public string strFobPoint { get; set; }
        public int? intShiftNumber { get; set; }
        public decimal? dblInvoiceAmount { get; set; }
        public bool? ysnPrepaid { get; set; }
        public bool? ysnInvoicePaid { get; set; }
        public int? intCheckNo { get; set; }
        public DateTime? dtmCheckDate { get; set; }
        public int? intTrailerTypeId { get; set; }
        public DateTime? dtmTrailerArrivalDate { get; set; }
        public DateTime? dtmTrailerArrivalTime { get; set; }
        public string strSealNo { get; set; }
        public string strSealStatus { get; set; }
        public DateTime? dtmReceiveTime { get; set; }
        public decimal? dblActualTempReading { get; set; }
        public int? intShipmentId { get; set; }
        public int? intTaxGroupId { get; set; }
        public string strTaxGroup { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public string strEntityName { get; set; }
        public string strActualCostId { get; set; }
        public string strWarehouseRefNo { get; set; }
        public decimal? dblSubTotal { get; set; }
        public decimal? dblTotalTax { get; set; }
        public decimal? dblTotalCharges { get; set; }
        public decimal? dblTotalGross { get; set; }
        public decimal? dblTotalNet { get; set; }
        public decimal? dblGrandTotal { get; set; }

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
    }

    public class vyuICInventoryReceiptLookUp
    {
        public int intInventoryReceiptId { get; set; }
        public string strVendorName { get; set; }
        public int? intEntityId { get; set; }
        public string strFobPoint { get; set; }
        public string strLocationName { get; set; }
        public string strCurrency { get; set; }
        public string strFromLocation { get; set; }
        public string strUserName { get; set; }
        public string strShipFrom { get; set; }
        public string strShipVia { get; set; }
        public string strFreightTerm { get; set; }
        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
    }

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

        private string _orderNumber;
        [NotMapped]
        public string strOrderNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_orderNumber))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strOrderNumber;
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
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strSourceNumber;
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
        private DateTime? _orderDate = null;
        [NotMapped]
        public DateTime? dtmOrderDate
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dtmDate;
                else
                    return _orderDate;
            }
            set
            {
                _orderDate = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strItemNo;
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
        private string _itemDescription;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDescription))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strItemDescription;
                    else
                        return null;
                else
                    return _itemDescription;
            }
            set
            {
                _itemDescription = value;
            }
        }
        private string _lotTracking;
        [NotMapped]
        public string strLotTracking
        {
            get
            {
                if (string.IsNullOrEmpty(_lotTracking))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strLotTracking;
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
        private string _orderUOM;
        [NotMapped]
        public string strOrderUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_orderUOM))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strOrderUOM;
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
        private decimal _orderedQty;
        [NotMapped]
        public decimal dblOrdered
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblOrdered ?? 0;
                else
                    return _orderedQty;
            }
            set
            {
                _orderedQty = value;
            }
        }
        private decimal _receivedQty;
        [NotMapped]
        public decimal dblReceived
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblReceived ?? 0;
                else
                    return _receivedQty;
            }
            set
            {
                _receivedQty = value;
            }
        }
        private decimal _orderConvFactor;
        [NotMapped]
        public decimal dblOrderUOMConvFactor
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblOrderUOMConvFactor ?? 0;
                else
                    return _orderConvFactor;
            }
            set
            {
                _orderConvFactor = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strUnitMeasure;
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

        private int? _uomId;
        [NotMapped]
        public int? intItemUOMId
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.intItemUOMId;
                return null;
            }
            set
            {
                this._uomId = value;
            }
        }

        private int? _uomDecimals;
        [NotMapped]
        public int? intItemUOMDecimalPlaces
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.intItemUOMDecimalPlaces;
                return null;
            }
            set
            {
                this._uomDecimals = value;
            }
        }

        private string _uomType;
        [NotMapped]
        public string strUnitType
        {
            get
            {
                if (string.IsNullOrEmpty(_uomType))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strUnitType;
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
        private string _subLocationName;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocationName))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strSubLocationName;
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
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strStorageLocationName;
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
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strGrade;
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
        private int? _commodityId;
        [NotMapped]
        public int? intCommodityId
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.intCommodityId;
                else
                    return null;
            }
            set
            {
                _commodityId = value;
            }
        }
        private string _weigthUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weigthUOM))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strWeightUOM;
                    else
                        return null;
                else
                    return _weigthUOM;
            }
            set
            {
                _weigthUOM = value;
            }
        }
        private string _container;
        [NotMapped]
        public string strContainer
        {
            get
            {
                if (string.IsNullOrEmpty(_container))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strContainer;
                    else
                        return null;
                else
                    return _container;
            }
            set
            {
                _container = value;
            }
        }
        private decimal _itemConv;
        [NotMapped]
        public decimal dblItemUOMConvFactor
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblItemUOMConvFactor ?? 0;
                else
                    return _itemConv;
            }
            set
            {
                _itemConv = value;
            }
        }
        private decimal _weightConv;
        [NotMapped]
        public decimal dblWeightUOMConvFactor
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblWeightUOMConvFactor ?? 0;
                else
                    return _weightConv;
            }
            set
            {
                _weightConv = value;
            }
        }
        private decimal _grossMargin;
        [NotMapped]
        public decimal dblGrossMargin
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblGrossMargin ?? 0;
                else
                    return _grossMargin;
            }
            set
            {
                _grossMargin = value;
            }
        }
        private string _lifetimeType;
        [NotMapped]
        public string strLifeTimeType
        {
            get
            {
                if (string.IsNullOrEmpty(_lifetimeType))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strLifeTimeType;
                    else
                        return null;
                else
                    return _lifetimeType;
            }
            set
            {
                _lifetimeType = value;
            }
        }
        private int _lifetime;
        [NotMapped]
        public int intLifeTime
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.intLifeTime ?? 0;
                else
                    return _lifetime;
            }
            set
            {
                _lifetime = value;
            }
        }
        private string _costUOM;
        [NotMapped]
        public string strCostUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_costUOM))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strCostUOM;
                    else
                        return null;
                else
                    return _costUOM;
            }
            set
            {
                _costUOM = value;
            }
        }
        private decimal _costCF;
        [NotMapped]
        public decimal dblCostUOMConvFactor
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblCostUOMConvFactor ?? 0;
                else
                    return _costCF;
            }
            set
            {
                _costCF = value;
            }
        }
        private bool _loadContract;
        [NotMapped]
        public bool ysnLoad
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.ysnLoad ?? false;
                else
                    return _loadContract;
            }
            set
            {
                _loadContract = value;
            }
        }
        private decimal _availableQty;
        [NotMapped]
        public decimal dblAvailableQty
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblAvailableQty ?? 0;
                else
                    return _availableQty;
            }
            set
            {
                _availableQty = value;
            }
        }
        private string _discountSchedule;
        [NotMapped]
        public string strDiscountSchedule
        {
            get
            {
                if (string.IsNullOrEmpty(_discountSchedule))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strDiscountSchedule;
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
        private decimal _franchise;
        [NotMapped]
        public decimal dblFranchise
        {
            get
            {
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblFranchise ?? 0;
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
                if (vyuICInventoryReceiptItemLookUp != null)
                    return vyuICInventoryReceiptItemLookUp.dblContainerWeightPerQty ?? 0;
                else
                    return _containerWeightPerQty;
            }
            set
            {
                _containerWeightPerQty = value;
            }
        }
        private string _subSubCurrency;
        [NotMapped]
        public string strSubCurrency
        {
            get
            {                               
                if (string.IsNullOrEmpty(_subSubCurrency))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strSubCurrency;
                    else
                        return null;
                else
                    return _subSubCurrency;
            }
            set
            {
                _subSubCurrency = value;
            }
        }
        private string _pricingType;
        [NotMapped]
        public string strPricingType
        {
            get
            {
                if (string.IsNullOrEmpty(_pricingType))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strPricingType;
                    else
                        return null;
                else
                    return _pricingType;
            }
            set
            {
                _pricingType = value;
            }
        }
        private string _itemTaxGroup;
        [NotMapped]
        public string strTaxGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_itemTaxGroup))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strTaxGroup;
                    else
                        return null;
                else
                    return _itemTaxGroup;
            }
            set
            {
                _itemTaxGroup = value;
            }
        }
        private string _forexRateType; 
        [NotMapped]
        public string strForexRateType
        {
            get
            {
                if (string.IsNullOrEmpty(_forexRateType))
                    if (vyuICInventoryReceiptItemLookUp != null)
                        return vyuICInventoryReceiptItemLookUp.strForexRateType;
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

    public class vyuICGetInventoryReceiptItemView
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intItemId { get; set; }
        public int intSourceId { get; set; }
        public decimal? dblReceived { get; set; }
        public decimal? dblBillQty { get; set; }
        public string strSourceType { get; set; }
        public string strOrderNumber { get; set; }
        public string strSourceNumber { get; set; }
        public int intRecordNo { get; set; }
    }

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

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class tblICInventoryReceiptCharge : BaseEntity
    {
        public tblICInventoryReceiptCharge()
        {
            this.tblICInventoryReceiptChargeTaxes = new List<tblICInventoryReceiptChargeTax>();
        }
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intContractId { get; set; }
        public int? intContractDetailId { get; set; }
        public int? intChargeId { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public bool? ysnPrice { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public int? intSort { get; set; }
        public int? intCurrencyId { get; set; }
   //     public decimal? dblExchangeRate { get; set; }
   //     public int? intCent { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public decimal? dblTax { get; set; }
        public int? intTaxGroupId { get; set; }

        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }

        private string _contractNo;
        [NotMapped]
        public string strContractNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_contractNo))
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strContractNumber;
                    else
                        return null;
                else
                    return _contractNo;
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
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strItemNo;
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
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strItemDescription;
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
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strCostUOM;
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
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strUnitType;
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
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strOnCostType;
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
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strVendorId;
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
        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strVendorName;
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

        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strCurrency;
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

        private string _chargeTaxGroup;
        [NotMapped]
        public string strTaxGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_chargeTaxGroup))
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strTaxGroup;
                    else
                        return null;
                else
                    return _chargeTaxGroup;
            }
            set
            {
                _chargeTaxGroup = value;
            }
        }

        private string _forexRateType;
        [NotMapped]
        public string strForexRateType
        {
            get
            {
                if (string.IsNullOrEmpty(_forexRateType))
                    if (vyuICGetInventoryReceiptCharge != null)
                        return vyuICGetInventoryReceiptCharge.strForexRateType;
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

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public vyuICGetInventoryReceiptCharge vyuICGetInventoryReceiptCharge { get; set; }
        public ICollection<tblICInventoryReceiptChargeTax> tblICInventoryReceiptChargeTaxes { get; set; }
    }

    public class vyuICGetInventoryReceiptCharge
    {
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intContractId { get; set; }
        public string strContractNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public bool? ysnPrice { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public string strCurrency { get; set; }
     //   public int? intCent { get; set; }
        public string strTaxGroup { get; set; }
        public decimal? dblTax { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strLocationName { get; set; }
        public string strBillOfLading { get; set; }
        public string strReceiptVendor { get; set; }
        public string strForexRateType { get; set; }

        public tblICInventoryReceiptCharge tblICInventoryReceiptCharge { get; set; }
    }

    public class vyuICGetInventoryReceiptItemLot
    {
        public int intInventoryReceiptItemLotId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public string strReceiptNumber { get; set; }
        public string strReceiptType { get; set; }
        public string strOrderNumber { get; set; }
        public string strLocationName { get; set; }
        public string strSourceType { get; set; }
        public string strSourceNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strBillOfLading { get; set; }
        public bool? ysnPosted { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strItemUOM { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblNetWeight { get; set; }
        public decimal? dblCost { get; set; }
        public int? intUnitPallet { get; set; }
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public string strContainerNo { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strGarden { get; set; }
        public string strMarkings { get; set; }
        public int? intOriginId { get; set; }
        public string strOrigin { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public int? intSeasonCropYear { get; set; }
        public string strVendorLotId { get; set; }
        public DateTime? dtmManufacturedDate { get; set; }
        public string strRemarks { get; set; }
        public string strCondition { get; set; }
        public DateTime? dtmCertified { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int? intSort { get; set; }
        public int? intParentLotId { get; set; }
        public string strParentLotNumber { get; set; }
        public string strParentLotAlias { get; set; }
        public decimal? dblStatedNetPerUnit { get; set; }
        public decimal? dblStatedTotalNet { get; set; }
        public decimal? dblPhysicalVsStated { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }

        public tblICInventoryReceiptItemLot tblICInventoryReceiptItemLot { get; set; }
    }

    public class tblICInventoryReceiptItemTax : BaseEntity
    {
        public int intInventoryReceiptItemTaxId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intTaxCodeId { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public int? intTaxAccountId { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnSeparateOnInvoice { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public string strTaxCode { get; set; }
        public int? intSort { get; set; }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class vyuICGetInventoryReceiptItemTax
    {
        public int intInventoryReceiptItemTaxId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intTaxGroupId { get; set; }
        public string strTaxGroup { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxClass { get; set; }
        public int? intTaxCodeId { get; set; }
        public string strTaxCode { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public int? intTaxAccountId { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnSeparateOnInvoice { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public int? intSort { get; set; }
    }

    public class tblICInventoryReceiptInspection : BaseEntity
    {
        public int intInventoryReceiptInspectionId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intQAPropertyId { get; set; }
        public bool ysnSelected { get; set; }
        public int intSort { get; set; }
        public string strPropertyName { get; set; }
       /* private string _propertyName;
        [NotMapped]
        public string strPropertyName
        {
            get
            {
                if (string.IsNullOrEmpty(_propertyName))
                    if (tblMFQAProperty != null)
                        return tblMFQAProperty.strPropertyName;
                    else
                        return null;
                else
                    return _propertyName;
            }
            set
            {
                _propertyName = value;
            }
        }
        private string _description;
        [NotMapped]
        public string strDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_description))
                    if (tblMFQAProperty != null)
                        return tblMFQAProperty.strDescription;
                    else
                        return null;
                else
                    return _description;
            }
            set
            {
                _description = value;
            }
        }*/

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        //public tblMFQAProperty tblMFQAProperty { get; set; }
    }

    public class vyuICGetReceiptAddOrder
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
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }
    }

    public class vyuICGetReceiptAddPurchaseOrder
    {
        public int? intKey { get; set; }
        public int? intLocationId { get; set; }
        public int? intEntityId { get; set; }
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
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }
    }

    //public class vyuICGetInventoryReceiptVoucher
    //{
    //    public int intInventoryReceiptId { get; set; }
    //    public int intInventoryReceiptItemId { get; set; }
    //    public string strVendor { get; set; }
    //    public string strLocationName { get; set; }
    //    public string strReceiptNumber { get; set; }
    //    public DateTime? dtmReceiptDate { get; set; }
    //    public string strBillOfLading { get; set; }
    //    public string strReceiptType { get; set; }
    //    public string strOrderNumber { get; set; }
    //    public string strItemDescription { get; set; }
    //    public decimal? dblUnitCost { get; set; }
    //    public decimal? dblQtyToReceive { get; set; }
    //    public decimal? dblLineTotal { get; set; }
    //    public decimal? dblQtyVouchered { get; set; }
    //    public decimal? dblVoucherAmount { get; set; }
    //    public decimal? dblQtyToVoucher { get; set; }
    //    public decimal? dblAmountToVoucher { get; set; }
    //    public string strBillId { get; set; }
    //    public DateTime? dtmBillDate { get; set; }
    //    public int intBillId { get; set; }
    //}

    public class vyuICGetInventoryReceiptVoucher
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strVendor { get; set; }
        public string strLocationName { get; set; }
        public string strReceiptNumber { get; set; }
        public string strBillOfLading { get; set; }
        public string strReceiptType { get; set; }
        public string strOrderNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblReceiptQty { get; set; }
        public decimal? dblVoucherQty { get; set; }
        public decimal? dblReceiptLineTotal { get; set; }
        public decimal? dblVoucherLineTotal { get; set; }
        public decimal? dblReceiptTax { get; set; }
        public decimal? dblVoucherTax { get; set; }
        public decimal? dblOpenQty { get; set; }
        public decimal? dblItemsPayable { get; set; }
        public decimal? dblTaxesPayable { get; set; }
        public DateTime? dtmLastVoucherDate { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strAllVouchers { get; set; }
        public string strFilterString { get; set; }
        public string strContainerNumber { get; set; }
        public int? intLoadContainerId { get; set; }
        public string strItemUOM { get; set; }
        public int? intItemUOMId { get; set; }
        public string strCostUOM { get; set; }
        public int? intCostUOMId { get; set; }
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }

    }

    public class vyuICGetReceiptAddTransferOrder
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
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }
    }

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
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }
    }

    public class vyuICGetReceiptAddLGInboundShipment
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
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }
    }

    public class tblICInventoryReceiptChargeTax : BaseEntity
    {
        public int intInventoryReceiptChargeTaxId { get; set; }
        public int intInventoryReceiptChargeId { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intTaxCodeId { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public int? intTaxAccountId { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public string strTaxCode { get; set; }
        public int? intSort { get; set; }

        public tblICInventoryReceiptCharge tblICInventoryReceiptCharge { get; set; }
    }

    public class vyuICGetInventoryReceiptChargeTax
    {
        public int intInventoryReceiptChargeTaxId { get; set; }
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intChargeId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intTaxGroupId { get; set; }
        public string strTaxGroup { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxClass { get; set; }
        public int? intTaxCodeId { get; set; }
        public string strTaxCode { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public int? intTaxAccountId { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public int? intSort { get; set; }
    }

    public class vyuICGetChargeTaxDetails
    {
        public int? intKey { get; set; }
        public int? intInventoryReceiptChargeTaxId { get; set; }
        public int? intInventoryReceiptId { get; set; }
        public int? intChargeId { get; set; }
        public string strItemNo { get; set; }
        public string strTaxGroup { get; set; }
        public string strTaxCode { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
    }
}
