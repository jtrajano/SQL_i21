using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStockUOMTotalsAllLocations
    {
        public int? intStorageLocationId { get; set; }
        public int intItemStockUOMId { get; set; }
        public int? intLocationId { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public decimal? dblStorageQty { get; set; }
        public decimal? dblOnHand { get; set; }
        public bool ysnStockUnit { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intAllowNegativeInventory { get; set; }
    }
}
