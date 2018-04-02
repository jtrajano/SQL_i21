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
        public int intConcurrencyId { get; set; }
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
        public int? intOwnershipType { get; set; }

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
        public string strSubLocation { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocation { get; set; }
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
        public string strNewSubLocation { get; set; }
        public int? intNewStorageLocationId { get; set; }
        public string strNewStorageLocation { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intSort { get; set; }
        public string strOwnerName { get; set; }
        public string strNewOwnerName { get; set; }
        public int? intOwnershipType { get; set; }
        public string strOwnershipType { get; set; }
        public int intConcurrencyId { get; set; }

        public tblICInventoryAdjustmentDetail tblICInventoryAdjustmentDetail { get; set; }
    }
}
