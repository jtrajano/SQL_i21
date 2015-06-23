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
        public int? intBlanketRelease { get; set; }
        public string strVendorRefNo { get; set; }
        public string strBillOfLading { get; set; }
        public int? intShipViaId { get; set; }
        public int? intShipFromId { get; set; }
        public int? intReceiverId { get; set; }
        public string strVessel { get; set; }
        public int? intFreightTermId { get; set; }
        public string strAllocateFreight { get; set; }
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
        public bool? ysnPosted { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intEntityId { get; set; }

        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuAPVendor != null)
                        return vyuAPVendor.strName;
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
        private int _vendorEntity;
        [NotMapped]
        public int intVendorEntityId
        {
            get
            {
                if (vyuAPVendor != null)
                    return vyuAPVendor.intEntityId;
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
                    if (tblSMFreightTerm != null)
                        return tblSMFreightTerm.strFobPoint;
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
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
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

        public ICollection<tblICInventoryReceiptInspection> tblICInventoryReceiptInspections { get; set; }
        public ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
        public ICollection<tblICInventoryReceiptCharge> tblICInventoryReceiptCharges { get; set; }

        public vyuAPVendor vyuAPVendor { get; set; }
        public tblSMFreightTerm tblSMFreightTerm { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; } 
    }

    public class RecieptVM
    {
        public int intInventoryReceiptId { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strReceiptType { get; set; }
        public string strVendorName { get; set; }
        public string strLocationName { get; set; }
        public bool ysnPosted { get; set; }
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
        public int intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public int? intSourceId { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public int intOwnershipType { get; set; }
        public decimal? dblOrderQty { get; set; }
        public decimal? dblBillQty { get; set; }
        public decimal? dblOpenReceive { get; set; }
        public decimal? dblReceived { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblUnitRetail { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intSort { get; set; }

        private string _orderNumber;
        [NotMapped]
        public string strOrderNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_orderNumber))
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strOrderNumber;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strSourceNumber;
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
                if (vyuICGetInventoryReceiptItem != null)
                    return vyuICGetInventoryReceiptItem.dtmDate;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strItemNo;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strItemDescription;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strLotTracking;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strUnitMeasure;
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
        private decimal _orderConvFactor;
        [NotMapped]
        public decimal dblOrderUOMConvFactor
        {
            get
            {
                if (vyuICGetInventoryReceiptItem != null)
                    return vyuICGetInventoryReceiptItem.dblOrderUOMConvFactor ?? 0;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strUnitMeasure;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strUnitType;
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
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strSubLocationName;
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
        string _weigthUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weigthUOM))
                    if (vyuICGetInventoryReceiptItem != null)
                        return vyuICGetInventoryReceiptItem.strWeightUOM;
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
        private decimal _itemConv;
        [NotMapped]
        public decimal dblItemUOMConvFactor
        {
            get
            {
                if (vyuICGetInventoryReceiptItem != null)
                    return vyuICGetInventoryReceiptItem.dblItemUOMConvFactor ?? 0;
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
                if (vyuICGetInventoryReceiptItem != null)
                    return vyuICGetInventoryReceiptItem.dblWeightUOMConvFactor ?? 0;
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
                if (vyuICGetInventoryReceiptItem != null)
                    return vyuICGetInventoryReceiptItem.dblGrossMargin ?? 0;
                else
                    return _grossMargin;
            }
            set
            {
                _grossMargin = value;
            }
        }
        

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public tblICItem tblICItem { get; set; }

        public vyuICGetInventoryReceiptItem vyuICGetInventoryReceiptItem { get; set; }
        public ICollection<tblICInventoryReceiptItemLot> tblICInventoryReceiptItemLots { get; set; }
        public ICollection<tblICInventoryReceiptItemTax> tblICInventoryReceiptItemTaxes { get; set; }
    }

    public class vyuICGetInventoryReceiptItem
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public DateTime? dtmDate { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblItemUOMConvFactor { get; set; }
        public decimal? dblWeightUOMConvFactor { get; set; }
        public decimal? dblGrossMargin { get; set; }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class tblICInventoryReceiptCharge : BaseEntity
    {
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intChargeId { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public int? intEntityVendorId { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public string strCostBilledBy { get; set; }
        public int? intSort { get; set; }

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

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public vyuICGetInventoryReceiptCharge vyuICGetInventoryReceiptCharge { get; set; }
    }

    public class vyuICGetInventoryReceiptCharge
    {
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public string strVendorId { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public string strCostBilledBy { get; set; }

        public tblICInventoryReceiptCharge tblICInventoryReceiptCharge { get; set; }
    }

    public class tblICInventoryReceiptItemLot : BaseEntity
    {
        public int intInventoryReceiptItemLotId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        
        public decimal? dblCost { get; set; }
        public int? intUnitPallet { get; set; }
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public string strContainerNo { get; set; }
        public int? intEntityVendorId { get; set; }
        public int? intVendorLocationId { get; set; }
        public string strVendorLocation { get; set; }
        public string strMarkings { get; set; }
        public string strGrade { get; set; }
        public int? intOriginId { get; set; }
        public int? intSeasonCropYear { get; set; }
        public string strVendorLotId { get; set; }
        public DateTime? dtmManufacturedDate { get; set; }
        public string strRemarks { get; set; }
        public string strCondition { get; set; }
        public DateTime? dtmCertified { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int? intSort { get; set; }

        [NotMapped]
        public decimal dblNetWeight
        {
            get
            {
                return (this.dblGrossWeight ?? 0) - (this.dblTareWeight ?? 0);
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
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
                    if (tblICInventoryReceiptItem != null)
                        return tblICInventoryReceiptItem.strWeightUOM;
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
        private decimal _lotConv;
        [NotMapped]
        public decimal dblLotUOMConvFactor
        {
            get
            {
                if (tblICItemUOM != null)
                    return tblICItemUOM.dblUnitQty ?? 0;
                else
                    return _lotConv;
            }
            set
            {
                _lotConv = value;
            }
        }
        private string _storageLocation;
        [NotMapped]
        public string strStorageLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocation))
                    if (tblICStorageLocation != null)
                        return tblICStorageLocation.strName;
                    else
                        return null;
                else
                    return _storageLocation;
            }
            set
            {
                _storageLocation = value;
            }
        }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
        public tblICLot tblICLot { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblICStorageLocation tblICStorageLocation { get; set; }
    }

    public class tblICInventoryReceiptItemTax : BaseEntity
    {
        public int intInventoryReceiptItemTaxId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intTaxCodeId { get; set; }
        public bool ysnSelected { get; set; }
        public int intSort { get; set; }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class tblICInventoryReceiptInspection : BaseEntity
    {
        public int intInventoryReceiptInspectionId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intQAPropertyId { get; set; }
        public bool ysnSelected { get; set; }
        public int intSort { get; set; }

        private string _propertyName;
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
        }

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public tblMFQAProperty tblMFQAProperty { get; set; }
    }
}
