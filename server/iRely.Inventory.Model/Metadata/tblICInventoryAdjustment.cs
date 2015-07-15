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
        public bool ysnPosted { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
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

        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public ICollection<tblICInventoryAdjustmentDetail> tblICInventoryAdjustmentDetails { get; set; }
    }

    public class AdjustmentVM : BaseEntity
    {
        [Key]
        public int intInventoryAdjustmentId { get; set; }
        public int? intLocationId { get; set; }
        public DateTime? dtmAdjustmentDate { get; set; }
        public int? intAdjustmentType { get; set; }
        public string strAdjustmentNo { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }
        public string strLocationName{ get; set; }
        public bool ysnPosted { get; set; }
    
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

        // 1: Sub Location
        private string _subLocation;
        [NotMapped]
        public string strSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (tblSMCompanyLocationSubLocation != null)
                        return tblSMCompanyLocationSubLocation.strSubLocationName;
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

        // 3: Item & New Item
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (Item != null)
                        return Item.strItemNo;
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
                    if (NewItem != null)
                        return NewItem.strItemNo;
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
                    if (Item != null)
                        return Item.strDescription;
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
                    if (NewItem != null)
                        return NewItem.strDescription;
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
                    if (Lot != null)
                        return Lot.strLotNumber;
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
        //private string _newLotNumber;
        //[NotMapped]
        //public string strNewLotNumber
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_newLotNumber))
        //            if (NewLot != null)
        //                return NewLot.strLotNumber;
        //            else
        //                return null;
        //        else
        //            return _newLotNumber;
        //    }
        //    set
        //    {
        //        _newLotNumber = value;
        //    }
        //}    
        
        // 6: Lot Qty, Lot Cost, and Weight Per Qty
        private decimal _lotQty;
        [NotMapped]
        public decimal dblLotQty
        {
            get
            {
                if (Lot != null)
                    return Lot.dblQty ?? 0;
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
                if (Lot != null)
                    return Lot.dblLastCost ?? 0;
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
                if (Lot != null)
                    return Lot.dblWeightPerQty ?? 0;
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
                    if (ItemUOM != null)
                        return ItemUOM.strUnitMeasure;
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
                    if (NewItemUOM != null)
                        return NewItemUOM.strUnitMeasure;
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
                    if (Lot != null)
                        return Lot.strWeightUOM;
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
                    if (NewWeightUOM != null)
                        return NewWeightUOM.strUnitMeasure;
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
                    if (OldLotStatus != null)
                        return OldLotStatus.strSecondaryStatus;
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
                    if (NewLotStatus != null)
                        return NewLotStatus.strSecondaryStatus;
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
                    if (Item != null)
                        return Item.strLotTracking;
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
                    if (NewLocation != null)
                        return NewLocation.strLocationName;
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


        // 12. New Sub Location 
        private string _strNewSubLocation;
        [NotMapped]
        public string strNewSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_strNewSubLocation))
                    if (NewSubLocation != null)
                        return NewSubLocation.strSubLocationName;
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
                    if (NewStorageLocation != null)
                        return NewStorageLocation.strName;
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
                    if (ItemUOM != null)
                        return ItemUOM.dblUnitQty;
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
                    if (NewItemUOM != null)
                        return NewItemUOM.dblUnitQty;
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

        public tblICInventoryAdjustment tblICInventoryAdjustment { get; set; }
        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        public tblICStorageLocation tblICStorageLocation { get; set; }

        public tblSMCompanyLocation NewLocation { get; set; }
        public tblSMCompanyLocationSubLocation NewSubLocation { get; set; }
        public tblICStorageLocation NewStorageLocation { get; set; }
        
        public tblICItem Item { get; set; }
        public tblICItem NewItem { get; set; }
        public tblICLot Lot { get; set; }
        public tblICLot NewLot { get; set; }
        public tblICItemUOM ItemUOM { get; set; }
        public tblICItemUOM NewItemUOM { get; set; }
        public tblICItemUOM WeightUOM { get; set; }
        public tblICItemUOM NewWeightUOM { get; set; }
        public tblICLotStatus OldLotStatus { get; set; }
        public tblICLotStatus NewLotStatus { get; set; }
    }
}
