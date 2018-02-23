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
        public string strCountBy { get; set; }
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
        public string strShiftNo { get; set; }
        public int? intLockType { get; set; }

        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (vyuICGetInventoryCount != null)
                        return vyuICGetInventoryCount.strLocationName;
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
        public string strSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (vyuICGetInventoryCount != null)
                        return vyuICGetInventoryCount.strSubLocationName;
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
        public string strStorageLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocation))
                    if (vyuICGetInventoryCount != null)
                        return vyuICGetInventoryCount.strStorageLocationName;
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

        private string _category;
        [NotMapped]
        public string strCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_category))
                    if (vyuICGetInventoryCount != null)
                        return vyuICGetInventoryCount.strCategory;
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

        private string _commodity;
        [NotMapped]
        public string strCommodity
        {
            get
            {
                if (string.IsNullOrEmpty(_commodity))
                    if (vyuICGetInventoryCount != null)
                        return vyuICGetInventoryCount.strCommodity;
                    else
                        return null;
                else
                    return _commodity;
            }
            set
            {
                _commodity = value;
            }
        }

        private string _countGroup;
        [NotMapped]
        public string strCountGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_countGroup))
                    if (vyuICGetInventoryCount != null)
                        return vyuICGetInventoryCount.strCountGroup;
                    else
                        return null;
                else
                    return _countGroup;
            }
            set
            {
                _countGroup = value;
            }
        }

        public ICollection<tblICInventoryCountDetail> tblICInventoryCountDetails { get; set; }
        public vyuICGetInventoryCount vyuICGetInventoryCount { get; set; }
    }

    public class tblICInventoryCountDetail : BaseEntity
    {
        public int intInventoryCountDetailId { get; set; }
        public int? intInventoryCountId { get; set; }
        public int? intItemId { get; set; }
        public int? intCountGroupId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intLotId { get; set; }
        public string strLotNo { get; set; }
        public string strLotAlias { get; set; }
        public int? intParentLotId { get; set; }
        public string strParentLotNo { get; set; }
        public string strParentLotAlias { get; set; }

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
        public decimal? dblQtyReceived { get; set; }
        public decimal? dblQtySold { get; set; }
        public int? intStockUOMId { get; set; }
        public decimal? dblWeightQty { get; set; }
        public decimal? dblNetQty { get; set; }
        public int? intWeightUOMId { get; set; }

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
        public string strCountBy { get; set; }
        public bool? ysnCountByPallets { get; set; }
        public bool? ysnRecountMismatch { get; set; }
        public bool? ysnExternal { get; set; }
        public bool? ysnRecount { get; set; }
        public int? intRecountReferenceId { get; set; }
        public string strShiftNo { get; set; }
        public int? intStatus { get; set; }
        public string strStatus { get; set; }
        public int? intSort { get; set; }
        public tblICInventoryCount tblICInventoryCount { get; set; }
    }

    public class vyuICGetInventoryCountDetail
    {
        public int? intInventoryCountDetailId { get; set; }
        public int? intInventoryCountId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public string strCountGroup { get; set; }
        public int? intCountGroupId { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intLotId { get; set; }
        public string strLotNo { get; set; }
        public string strLotAlias { get; set; }
        public int? intParentLotId { get; set; }
        public string strParentLotNo { get; set; }
        public string strParentLotAlias { get; set; }
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
        public decimal? dblQtyReceived { get; set; }
        public decimal? dblQtySold { get; set; }
        public int? intEntityUserSecurityId { get; set; }
        public string strUserName { get; set; }
        public int? intSort { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightQty { get; set; }
        public decimal? dblNetQty { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblItemUOMConversionFactor { get; set; }
        public decimal? dblWeightUOMConversionFactor { get; set; }
        public int? intStockUOMId { get; set; }
        public string strStockUOM { get; set; }
        public int? intConcurrencyId { get; set; }

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
