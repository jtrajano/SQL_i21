using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemRunningStock
    {
        public int intKey { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public string strItemUOMType { get; set; }
        public bool? ysnStockUnit { get; set; }
        public decimal? dblUnitQty { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public int? intOwnershipType { get; set; }
        public int? intItemOwnerId { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeight { get; set; }
        public decimal? dblWeightPerQty { get; set; }
        public int? intLotStatusId { get; set; }
        public string strLotStatus { get; set; }
        public string strLotPrimaryStatus { get; set; }
        public int? intOwnerId { get; set; }
        public string strOwner { get; set; }
        public DateTime? dtmAsOfDate { get; set; }
        public decimal? dblQty { get; set; }
        public decimal? dblCost { get; set; }
    }
}
