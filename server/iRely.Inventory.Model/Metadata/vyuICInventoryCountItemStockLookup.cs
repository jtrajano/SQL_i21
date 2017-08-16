using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryCountItemStockLookup : BaseEntity
    {
        public int intKey { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public decimal? dblOnHand { get; set; }
        public int? intItemStockUOMId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intItemUOMId { get; set; }
    }
}
