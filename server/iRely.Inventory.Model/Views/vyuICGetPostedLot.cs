using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class vyuICGetPostedLot 
    {
        public int intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strDescription { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblQty { get; set; }
        public decimal? dblWeight { get; set; }
        public decimal? dblWeightPerQty { get; set; }
        public decimal? dblCost { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int? intLotStatusId { get; set; }
        public string strLotStatus { get; set; }
        public string strLotPrimaryStatus { get; set; }
    }
}
