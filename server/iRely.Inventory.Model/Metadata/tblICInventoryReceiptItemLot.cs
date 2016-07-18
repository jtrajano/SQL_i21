using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
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
        public int? intNoPallet { get; set; }
        public int? intUnitPallet { get; set; }
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public string strContainerNo { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strGarden { get; set; }
        public string strMarkings { get; set; }
        public int? intOriginId { get; set; }
        public int? intGradeId { get; set; }
        public int? intSeasonCropYear { get; set; }
        public string strVendorLotId { get; set; }
        public DateTime? dtmManufacturedDate { get; set; }
        public string strRemarks { get; set; }
        public string strCondition { get; set; }
        public DateTime? dtmCertified { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int? intParentLotId { get; set; }
        public string strParentLotNumber { get; set; }
        public string strParentLotAlias { get; set; }
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
                    if (vyuICGetInventoryReceiptItemLot != null)
                        return vyuICGetInventoryReceiptItemLot.strUnitMeasure;
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
                if (vyuICGetInventoryReceiptItemLot != null)
                    return vyuICGetInventoryReceiptItemLot.dblUnitQty ?? 0;
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
                    if (vyuICGetInventoryReceiptItemLot != null)
                        return vyuICGetInventoryReceiptItemLot.strStorageLocationName;
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
        private string _subLocation;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (vyuICGetInventoryReceiptItemLot != null)
                        return vyuICGetInventoryReceiptItemLot.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocation;
            }
            set
            {
                _subLocation = value;
            }
        }
        private string _vendorId;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorId))
                    if (vyuICGetInventoryReceiptItemLot != null)
                        return vyuICGetInventoryReceiptItemLot.strVendorId;
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
        private string _origin;
        [NotMapped]
        public string strOrigin
        {
            get
            {
                if (string.IsNullOrEmpty(_origin))
                    if (vyuICGetInventoryReceiptItemLot != null)
                        return vyuICGetInventoryReceiptItemLot.strOrigin;
                    else
                        return null;
                else
                    return _origin;
            }
            set
            {
                _origin = value;
            }
        }
        private string _grade;
        [NotMapped]
        public string strGrade
        {
            get
            {
                if (string.IsNullOrEmpty(_grade))
                    if (vyuICGetInventoryReceiptItemLot != null)
                        return vyuICGetInventoryReceiptItemLot.strGrade;
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

        public tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
        public vyuICGetInventoryReceiptItemLot vyuICGetInventoryReceiptItemLot { get; set; }
    }
}
