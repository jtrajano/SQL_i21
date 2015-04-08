using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICLot : BaseEntity
    {
        public int intLotId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public string strLotNumber { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocation { get; set; }
        public decimal? dblQty { get; set; }
        public decimal? dblLastCost { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public string strLotAlias { get; set; }
        public int? intLotStatusId { get; set; }
        public string strLotStatus { get; set; }
        public int? intParentLotId { get; set; }
        public int? intSplitFromLotId { get; set; }
        public decimal? dblWeight { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightPerQty { get; set; }
        public int? intOriginId { get; set; }
        public string strBOLNo { get; set; }
        public string strVessel { get; set; }
        public string strReceiptNumber { get; set; }
        public string strMarkings { get; set; }
        public string strNotes { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorLotNo { get; set; }
        public int? intVendorLocationId { get; set; }
        public string strVendorLocation { get; set; }
        public string strContractNo { get; set; }
        public DateTime? dtmManufacturedDate { get; set; }
        public bool? ysnReleasedToWarehouse { get; set; }
        public bool? ysnProduced { get; set; }
        public DateTime? dtmDateCreated { get; set; }
        public int? intCreatedUserId { get; set; }

        public tblICInventoryReceiptItemLot tblICInventoryReceiptItemLot { get; set; }

        public ICollection<tblICInventoryAdjustmentDetail> tblICInventoryAdjustmentDetails { get; set; }
        public ICollection<tblICInventoryAdjustmentDetail> NewAdjustmentDetails { get; set; }

    }
}
