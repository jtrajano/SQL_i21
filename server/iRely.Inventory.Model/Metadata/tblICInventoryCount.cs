using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICInventoryCount : BaseEntity
    {
        public tblICInventoryCount()
        {
            this.tblICInventoryCountDetails = new List<tblICInventoryCountDetail>();
        }

        public int intInventoryCountId { get; set; }
        public int? intLocationId { get; set; }
        public int? intCategoryId { get; set; }
        public int? intCommodityId { get; set; }
        public int? intCountGroupId { get; set; }
        public DateTime? dtmCountDate { get; set; }
        public string strCountNo { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strDescription { get; set; }
        public bool? ysnIncludeZeroOnHand { get; set; }
        public bool? ysnIncludeOnHand { get; set; }
        public bool? ysnScannedCountEntry { get; set; }
        public bool? ysnCountByLots { get; set; }
        public bool? ysnCountByPallets { get; set; }
        public bool? ysnRecountMismatch { get; set; }
        public bool? ysnExternal { get; set; }
        public bool? ysnRecount { get; set; }
        public int? intRecountReferenceId { get; set; }
        public int? intStatus { get; set; }
        public bool? ysnPosted { get; set; }
        public DateTime? dtmPosted { get; set; }
        public int? intEntityId { get; set; }
        public int? intImportFlagInternal { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICInventoryCountDetail> tblICInventoryCountDetails { get; set; }
    }

    public class tblICInventoryCountDetail : BaseEntity
    {
        public int intInventoryCountDetailId { get; set; }
        public int? intInventoryCountId { get; set; }
        public int? intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intLotId { get; set; }
        public decimal? dblSystemCount { get; set; }
        public decimal? dblLastCost { get; set; }
        public string strCountLine { get; set; }
        public decimal? dblPallets { get; set; }
        public decimal? dblQtyPerPallet { get; set; }
        public decimal? dblPhysicalCount { get; set; }
        public int? intItemUOMId { get; set; }
        public bool? ysnRecount { get; set; }
        public int? intEntityUserSecurityId { get; set; }
        public int? intSort { get; set; }
        public string strAutoCreatedLotNumber { get; set; }

        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strItemNo;
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
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strItemDescription;
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
        private string _lotTracking;
        [NotMapped]
        public string strLotTracking
        {
            get
            {
                if (string.IsNullOrEmpty(_lotTracking))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strLotTracking;
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
        private string _category;
        [NotMapped]
        public string strCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_category))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strCategory;
                    else
                        return null;
                else
                    return _category;
            }
            set
            {
                _category = value;
            }
        }
        private int? _categoryId;
        [NotMapped]
        public int? intCategoryId
        {
            get
            {
                if (vyuICGetInventoryCountDetail != null)
                    return vyuICGetInventoryCountDetail.intCategoryId;
                else
                    return null;
            }
            set
            {
                _categoryId = value;
            }
        }
        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strLocationName;
                    else
                        return null;
                else
                    return _location;
            }
            set
            {
                _location = value;
            }
        }
        private string _subLocation;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strSubLocationName;
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
        private string _storageLocation;
        [NotMapped]
        public string strStorageLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocation))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strStorageLocationName;
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
        private string _lotNumber;
        [NotMapped]
        public string strLotNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_lotNumber))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strLotNumber;
                    else
                        return null;
                else
                    return _lotNumber;
            }
            set
            {
                _lotNumber = value;
            }
        }
        private string _lotAlias;
        [NotMapped]
        public string strLotAlias
        {
            get
            {
                if (string.IsNullOrEmpty(_lotAlias))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strLotAlias;
                    else
                        return null;
                else
                    return _lotAlias;
            }
            set
            {
                _lotAlias = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strUnitMeasure;
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
        private string _user;
        [NotMapped]
        public string strUserName
        {
            get
            {
                if (string.IsNullOrEmpty(_user))
                    if (vyuICGetInventoryCountDetail != null)
                        return vyuICGetInventoryCountDetail.strUserName;
                    else
                        return null;
                else
                    return _user;
            }
            set
            {
                _user = value;
            }
        }
        private decimal _countStockUnit;
        [NotMapped]
        public decimal dblPhysicalCountStockUnit
        {
            get
            {
                if (vyuICGetInventoryCountDetail != null)
                    return vyuICGetInventoryCountDetail.dblPhysicalCountStockUnit ?? 0;
                else
                    return _countStockUnit;
            }
            set
            {
                _countStockUnit = value;
            }
        }
        private decimal _variance;
        [NotMapped]
        public decimal dblVariance
        {
            get
            {
                if (vyuICGetInventoryCountDetail != null)
                    return vyuICGetInventoryCountDetail.dblVariance ?? 0;
                else
                    return _variance;
            }
            set
            {
                _variance = value;
            }
        }
        private decimal _convFactor;
        [NotMapped]
        public decimal dblConversionFactor
        {
            get
            {
                if (vyuICGetInventoryCountDetail != null)
                    return vyuICGetInventoryCountDetail.dblConversionFactor ?? 0;
                else
                    return _convFactor;
            }
            set
            {
                _convFactor = value;
            }
        }


        public tblICInventoryCount tblICInventoryCount { get; set; }
        public vyuICGetInventoryCountDetail vyuICGetInventoryCountDetail { get; set; }
    }

    public class vyuICGetInventoryCount
    {
        public int intInventoryCountId { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public int? intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public DateTime? dtmCountDate { get; set; }
        public string strCountNo { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public string strDescription { get; set; }
        public bool? ysnIncludeZeroOnHand { get; set; }
        public bool? ysnIncludeOnHand { get; set; }
        public bool? ysnScannedCountEntry { get; set; }
        public bool? ysnCountByLots { get; set; }
        public bool? ysnCountByPallets { get; set; }
        public bool? ysnRecountMismatch { get; set; }
        public bool? ysnExternal { get; set; }
        public bool? ysnRecount { get; set; }
        public int? intRecountReferenceId { get; set; }
        public int? intStatus { get; set; }
        public string strStatus { get; set; }
        public int? intSort { get; set; }
    }

    public class vyuICGetInventoryCountDetail
    {
        public int? intInventoryCountDetailId { get; set; }
        public int? intInventoryCountId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public decimal? dblSystemCount { get; set; }
        public decimal? dblLastCost { get; set; }
        public string strCountLine { get; set; }
        public decimal? dblPallets { get; set; }
        public decimal? dblQtyPerPallet { get; set; }
        public decimal? dblPhysicalCount { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblConversionFactor { get; set; }
        public decimal? dblPhysicalCountStockUnit { get; set; }
        public decimal? dblVariance { get; set; }
        public bool? ysnRecount { get; set; }
        public int? intEntityUserSecurityId { get; set; }
        public string strUserName { get; set; }
        public int? intSort { get; set; }
        
        public tblICInventoryCountDetail tblICInventoryCountDetail { get; set; }
    }

    public class vyuICGetCountSheet
    {
        public int intLocationId { get; set; }
        public int intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public string strCountNo { get; set; }
        public DateTime? dtmCountDate { get; set; }
        public int? intInventoryCountDetailId { get; set; }
        public int? intInventoryCountId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public decimal? dblSystemCount { get; set; }
        public decimal? dblLastCost { get; set; }
        public string strCountLine { get; set; }
        public decimal? dblPallets { get; set; }
        public decimal? dblQtyPerPallet { get; set; }
        public decimal? dblPhysicalCount { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblPhysicalCountStockUnit { get; set; }
        public decimal? dblVariance { get; set; }
        public bool? ysnRecount { get; set; }
        public int? intEntityUserSecurityId { get; set; }
        public string strUserName { get; set; }
        public int? intSort { get; set; }
        public bool? ysnCountByLots { get; set; }
        public bool? ysnCountByPallets { get; set; }
        public bool? ysnIncludeOnHand { get; set; }
        public bool? ysnIncludeZeroOnHand { get; set; }
        public decimal? dblPalletsBlank { get; set; }
        public decimal? dblQtyPerPalletBlank { get; set; }
        public decimal? dblPhysicalCountBlank { get; set; }
    }

    public class vyuICGetItemStockSummary
    {
        public int intKey { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intLocationId { get; set; }
        public int? intCountGroupId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblStockIn { get; set; }
        public decimal? dblStockOut { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblConversionFactor { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblTotalCost { get; set; }
    }

    public class vyuICGetItemStockSummaryByLot
    {
        public int intKey { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intLocationId { get; set; }
        public int? intCountGroupId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public decimal? dblStockIn { get; set; }
        public decimal? dblStockOut { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblConversionFactor { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblTotalCost { get; set; }
    }
}
