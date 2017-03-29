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
    public class tblICInventoryAdjustment : BaseEntity
    {
        public tblICInventoryAdjustment()
        {
            this.tblICInventoryAdjustmentDetails = new List<tblICInventoryAdjustmentDetail>();
        }

        public int intInventoryAdjustmentId { get; set; }
        public int? intLocationId { get; set; }
        public DateTime? dtmAdjustmentDate { get; set; }
        public int? intAdjustmentType { get; set; }
        public string strAdjustmentNo { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public DateTime? dtmPostedDate { get; set; }
        public DateTime? dtmUnpostedDate { get; set; }
        public int? intSourceId { get; set; }
        public int? intSourceTransactionTypeId { get; set; }

        private string _location;
        [NotMapped]
        public string strLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (vyuICGetInventoryAdjustment != null)
                        return vyuICGetInventoryAdjustment.strLocationName;
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

        public ICollection<tblICInventoryAdjustmentDetail> tblICInventoryAdjustmentDetails { get; set; }
        public vyuICGetInventoryAdjustment vyuICGetInventoryAdjustment { get; set; }
    }

    public class vyuICGetInventoryAdjustment
    {
        public int intInventoryAdjustmentId { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public DateTime? dtmAdjustmentDate { get; set; }
        public int? intAdjustmentType { get; set; }
        public string strAdjustmentType { get; set; }
        public string strAdjustmentNo { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public string strUser { get; set; }
        public DateTime? dtmPostedDate { get; set; }
        public DateTime? dtmUnpostedDate { get; set; }
        public int? intSourceId { get; set; }
        public int? intSourceTransactionTypeId { get; set; }
        public tblICInventoryAdjustment tblICInventoryAdjustment { get; set; }
    }

    public class tblICInventoryAdjustmentDetail : BaseEntity
    {
        public int intInventoryAdjustmentDetailId { get; set; }
        public int intInventoryAdjustmentId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }

        public int? intItemId { get; set; }
        public int? intNewItemId { get; set; }
        
        public int? intLotId { get; set; }
        public int? intNewLotId { get; set; }
        public string strNewLotNumber { get; set; }

        public decimal? dblQuantity { get; set; }
        public decimal? dblNewQuantity { get; set; }
        public decimal? dblAdjustByQuantity { get; set; }
        public decimal? dblNewSplitLotQuantity { get; set; }

        public int? intItemUOMId { get; set; }
        public int? intNewItemUOMId { get; set; }
        
        public int? intWeightUOMId { get; set; }
        public int? intNewWeightUOMId { get; set; }
        
        public decimal? dblWeight { get; set; }
        public decimal? dblNewWeight { get; set; }
        
        public decimal? dblWeightPerQty { get; set; }
        public decimal? dblNewWeightPerQty { get; set; }
        
        public DateTime? dtmExpiryDate { get; set; }
        public DateTime? dtmNewExpiryDate { get; set; }
        
        public int? intLotStatusId { get; set; }
        public int? intNewLotStatusId { get; set; }

        public decimal? dblCost { get; set; }
        public decimal? dblNewCost { get; set; }
        
        public decimal? dblLineTotal { get; set; }
        public int? intSort { get; set; }

        public int? intNewLocationId { get; set; }
        public int? intNewSubLocationId { get; set; }
        public int? intNewStorageLocationId { get; set; }

        public int? intItemOwnerId { get; set; }
        public int? intNewItemOwnerId { get; set; }

        // 1: Storage Location
        private string _subLocation;
        [NotMapped]
        public string strSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strSubLocationName;
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

        // 2: Storage Location
        private string _storageLocation;
        [NotMapped]
        public string strStorageLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocation))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strStorageLocationName;
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

        // 3: Item & New Item
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strItemNo;
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
        private string _newItemNo;
        [NotMapped]
        public string strNewItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_newItemNo))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewItemNo;
                    else
                        return null;
                else
                    return _newItemNo;
            }
            set
            {
                _newItemNo = value;
            }
        }


        // 4: Item Description & New Item Description
        private string _itemDesc;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDesc))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strItemDescription;
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
        private string _newItemDesc;
        [NotMapped]
        public string strNewItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_newItemDesc))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewItemDescription;
                    else
                        return null;
                else
                    return _newItemDesc;
            }
            set
            {
                _newItemDesc = value;
            }
        }


        // 5: Lot Number and New Lot Number
        private string _lotNumber;
        [NotMapped]
        public string strLotNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_lotNumber))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strLotNumber;
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
        
        // 6: Lot Qty, Lot Cost, and Weight Per Qty
        private decimal _lotQty;
        [NotMapped]
        public decimal dblLotQty
        {
            get
            {
                if (vyuICGetInventoryAdjustmentDetail != null)
                    return vyuICGetInventoryAdjustmentDetail.dblLotQty ?? 0;
                else
                    return 0;
            }
            set
            {
                _lotQty = value;
            }
        }
        private decimal _lotUnitCost;
        [NotMapped]
        public decimal dblLotUnitCost
        {
            get
            {
                if (vyuICGetInventoryAdjustmentDetail != null)
                    return vyuICGetInventoryAdjustmentDetail.dblLotUnitCost ?? 0;
                else
                    return 0;
            }
            set
            {
                _lotUnitCost = value;
            }
        }
        private decimal _lotWeightPerQty;
        [NotMapped]
        public decimal dblLotWeightPerQty
        {
            get
            {
                if (vyuICGetInventoryAdjustmentDetail != null)
                    return vyuICGetInventoryAdjustmentDetail.dblLotWeightPerQty ?? 0;
                else
                    return 0;
            }
            set
            {
                _lotWeightPerQty = value;
            }
        }


        // 7: Item UOM and New Item UOM
        private string _itemUOM;
        [NotMapped]
        public string strItemUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_itemUOM))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strItemUOM;
                    else
                        return null;
                else
                    return _itemUOM;
            }
            set
            {
                _itemUOM = value;
            }
        }
        private string _newItemUOM;
        [NotMapped]
        public string strNewItemUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_newItemUOM))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewItemUOM;
                    else
                        return null;
                else
                    return _newItemUOM;
            }
            set
            {
                _newItemUOM = value;
            }
        }

        // 8: Weight UOM and New Weight UOM
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strWeightUOM;
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
        private string _newWeightUOM;
        [NotMapped]
        public string strNewWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_newWeightUOM))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewWeightUOM;
                    else
                        return null;
                else
                    return _newWeightUOM;
            }
            set
            {
                _newWeightUOM = value;
            }
        }        

        // 9: Lot Status and New Lot Status
        private string _lotStatus;
        [NotMapped]
        public string strLotStatus
        {
            get
            {
                if (string.IsNullOrEmpty(_lotStatus))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strLotStatus;
                    else
                        return null;
                else
                    return _lotStatus;
            }
            set
            {
                _lotStatus = value;
            }
        }

        private string _newLotStatus;
        [NotMapped]
        public string strNewLotStatus
        {
            get
            {
                if (string.IsNullOrEmpty(_newLotStatus))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewLotStatus;
                    else
                        return null;
                else
                    return _newLotStatus;
            }
            set
            {
                _newLotStatus = value;
            }
        }

        // 10. Lot tracking
        private string _strLotTracking;
        [NotMapped]
        public string strLotTracking
        {
            get
            {
                if (string.IsNullOrEmpty(_strLotTracking))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strLotTracking;
                    else
                        return null;
                else
                    return _strLotTracking;
            }
            set
            {
                _strLotTracking = value;
            }
        }


        // 11. New Location 
        private string _strNewLocation;
        [NotMapped]
        public string strNewLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_strNewLocation))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewLocationName;
                    else
                        return null;
                else
                    return _strNewLocation;
            }
            set
            {
                _strNewLocation = value;
            }
        }


        // 12. New Storage Location 
        private string _strNewSubLocation;
        [NotMapped]
        public string strNewSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_strNewSubLocation))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewSubLocationName;
                    else
                        return null;
                else
                    return _strNewSubLocation;
            }
            set
            {
                _strNewSubLocation = value;
            }
        }

        // 13. New Storage Location. 
        private string _strNewStorageLocation;
        [NotMapped]
        public string strNewStorageLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_strNewStorageLocation))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewStorageLocationName;
                    else
                        return null;
                else
                    return _strNewStorageLocation;
            }
            set
            {
                _strNewStorageLocation = value;
            }
        }

        // 14: Unit Qty for Item UOM and New Item UOM
        private decimal? _itemUOMUnitQty;
        [NotMapped]
        public decimal? dblItemUOMUnitQty
        {
            get
            {
                if (_itemUOMUnitQty == null )
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.dblItemUOMUnitQty;
                    else
                        return null;
                else
                    return _itemUOMUnitQty;
            }
            set
            {
                _itemUOMUnitQty = value;
            }
        }
        private decimal? _newItemUOMUnitQty;
        [NotMapped]
        public decimal? dblNewItemUOMUnitQty
        {
            get
            {
                if (_newItemUOMUnitQty == null)
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.dblNewItemUOMUnitQty;
                    else
                        return null;
                else
                    return _newItemUOMUnitQty;
            }
            set
            {
                _newItemUOMUnitQty = value;
            }
        }

        private string _ownerName;
        [NotMapped]
        public string strOwnerName
        {
            get
            {
                if (string.IsNullOrEmpty(_ownerName))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strOwnerName;
                    else
                        return null;
                else
                    return _ownerName;
            }
            set
            {
                _ownerName = value;
            }
        }

        private string _newOwnerName;
        [NotMapped]
        public string strNewOwnerName
        {
            get
            {
                if (string.IsNullOrEmpty(_newOwnerName))
                    if (vyuICGetInventoryAdjustmentDetail != null)
                        return vyuICGetInventoryAdjustmentDetail.strNewOwnerName;
                    else
                        return null;
                else
                    return _newOwnerName;
            }
            set
            {
                _newOwnerName = value;
            }
        }

        public tblICInventoryAdjustment tblICInventoryAdjustment { get; set; }
        public vyuICGetInventoryAdjustmentDetail vyuICGetInventoryAdjustmentDetail { get; set; }
    }

    public class vyuICGetInventoryAdjustmentDetail
    {
        public int intInventoryAdjustmentDetailId { get; set; }
        public int intInventoryAdjustmentId { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public DateTime? dtmAdjustmentDate { get; set; }
        public int? intAdjustmentType { get; set; }
        public string strAdjustmentType { get; set; }
        public string strAdjustmentNo { get; set; }
        public string strDescription { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public string strUser { get; set; }
        public DateTime? dtmPostedDate { get; set; }
        public DateTime? dtmUnpostedDate { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intNewItemId { get; set; }
        public string strNewItemNo { get; set; }
        public string strNewItemDescription { get; set; }
        public string strNewLotTracking { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public decimal? dblLotQty { get; set; }
        public decimal? dblLotUnitCost { get; set; }
        public decimal? dblLotWeightPerQty { get; set; }
        public int? intNewLotId { get; set; }
        public string strNewLotNumber { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblNewQuantity { get; set; }
        public decimal? dblNewSplitLotQuantity { get; set; }
        public decimal? dblAdjustByQuantity { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMUnitQty { get; set; }
        public int? intNewItemUOMId { get; set; }
        public string strNewItemUOM { get; set; }
        public decimal? dblNewItemUOMUnitQty { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public int? intNewWeightUOMId { get; set; }
        public string strNewWeightUOM { get; set; }
        public decimal? dblWeight { get; set; }
        public decimal? dblNewWeight { get; set; }
        public decimal? dblWeightPerQty { get; set; }
        public decimal? dblNewWeightPerQty { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public DateTime? dtmNewExpiryDate { get; set; }
        public int? intLotStatusId { get; set; }
        public string strLotStatus { get; set; }
        public int? intNewLotStatusId { get; set; }
        public string strNewLotStatus { get; set; }
        public decimal? dblCost { get; set; }
        public decimal? dblNewCost { get; set; }
        public int? intNewLocationId { get; set; }
        public string strNewLocationName { get; set; }
        public int? intNewSubLocationId { get; set; }
        public string strNewSubLocationName { get; set; }
        public int? intNewStorageLocationId { get; set; }
        public string strNewStorageLocationName { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intSort { get; set; }
        public string strOwnerName { get; set; }
        public string strNewOwnerName { get; set; }

        public tblICInventoryAdjustmentDetail tblICInventoryAdjustmentDetail { get; set; }
    }
}
