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
        }

        public int intInventoryReceiptId { get; set; }
        public string strReceiptType { get; set; }
        public int? intVendorId { get; set; }
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
        public string strCalculationBasis { get; set; }
        public decimal? dblUnitWeightMile { get; set; }
        public decimal? dblFreightRate { get; set; }
        public decimal? dblFuelSurcharge { get; set; }
        public decimal? dblInvoiceAmount { get; set; }
        public bool ysnPrepaid { get; set; }
        public bool ysnInvoicePaid { get; set; }
        public int? intCheckNo { get; set; }
        public DateTime? dtmCheckDate { get; set; }
        public int? intTrailerTypeId { get; set; }
        public DateTime? dtmTrailerArrivalDate { get; set; }
        public DateTime? dtmTrailerArrivalTime { get; set; }
        public string strSealNo { get; set; }
        public string strSealStatus { get; set; }
        public DateTime? dtmReceiveTime { get; set; }
        public decimal? dblActualTempReading { get; set; }
        public bool ysnPosted { get; set; }
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

        public vyuAPVendor vyuAPVendor { get; set; }
        public tblSMFreightTerm tblSMFreightTerm { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; } 
    }

    public class vyuReciepts : BaseEntity
    {
        [Key]
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
        public int? intLineNo { get; set; }
        public int? intSourceId { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblOrderQty { get; set; }
        public decimal? dblOpenReceive { get; set; }
        public decimal? dblReceived { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intNoPackages { get; set; }
        public int? intPackageTypeId { get; set; }
        public decimal? dblExpPackageWeight { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intSort { get; set; }

        private string _sourceId;
        [NotMapped]
        public string strSourceId
        {
            get
            {
                if (string.IsNullOrEmpty(_sourceId))
                    if (vyuICGetReceiptItemSource != null)
                        return vyuICGetReceiptItemSource.strSourceId;
                    else
                        return null;
                else
                    return _sourceId;
            }
            set
            {
                _sourceId = value;
            }
        }
        private DateTime? _sourceDate = null;
        [NotMapped]
        public DateTime? dtmSourceDate
        {
            get
            {
                if (vyuICGetReceiptItemSource != null)
                    return vyuICGetReceiptItemSource.dtmDate;
                else
                    return _sourceDate;
            }
            set
            {
                _sourceDate = value;
            }
        }
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
        private string _itemDescription;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDescription))
                    if (tblICItem != null)
                        return tblICItem.strDescription;
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
                    if (tblICItem != null)
                        return tblICItem.strLotTracking;
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
        private string _packName;
        [NotMapped]
        public string strPackName
        {
            get
            {
                if (string.IsNullOrEmpty(_packName))
                    if (PackageType != null)
                        return PackageType.strUnitMeasure;
                    else
                        return null;
                else
                    return _packName;
            }
            set
            {
                _packName = value;
            }
        }
        private string _subLocationName;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocationName))
                    if (tblSMCompanyLocationSubLocation != null)
                        return tblSMCompanyLocationSubLocation.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocationName;
            }
            set
            {
                _packName = value;
            }
        }
        
        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public tblICItem tblICItem { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblICUnitMeasure PackageType { get; set; }
        public vyuICGetReceiptItemSource vyuICGetReceiptItemSource { get; set; }
        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        
        public ICollection<tblICInventoryReceiptItemLot> tblICInventoryReceiptItemLots { get; set; }
        public ICollection<tblICInventoryReceiptItemTax> tblICInventoryReceiptItemTaxes { get; set; }
    }

    public class vyuICGetReceiptItemSource
    {
        [Key]
        public int intInventoryReceiptItemId { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceId { get; set; }
        public DateTime? dtmDate { get; set; }

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class tblICInventoryReceiptItemLot : BaseEntity
    {
        public int intInventoryReceiptItemLotId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int? intParentLotId { get; set; }
        public int? intLotId { get; set; }
        public string strParentLotId { get; set; }
        public string strLotId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblCost { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intUnitUOMId { get; set; }
        public int? intUnits { get; set; }
        public int? intUnitPallet { get; set; }
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public string strContainerNo { get; set; }
        public int? intGarden { get; set; }
        public string strGrade { get; set; }
        public int? intOriginId { get; set; }
        public int? intSeasonCropYear { get; set; }
        public string strVendorLotId { get; set; }
        public DateTime? dtmManufacturedDate { get; set; }
        public string strRemarks { get; set; }
        public string strCondition { get; set; }
        public DateTime? dtmCertified { get; set; }
        public int? intSort { get; set; }

        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICInventoryReceiptItem != null)
                        return tblICInventoryReceiptItem.strUnitMeasure;
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

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
        public tblICLot tblICLot { get; set; }
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
