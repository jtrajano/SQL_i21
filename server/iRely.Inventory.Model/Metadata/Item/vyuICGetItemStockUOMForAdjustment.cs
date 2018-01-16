using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStockUOMForAdjustment
    {
        public int intItemStockUOMId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strType { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public bool? ysnStockUnit { get; set; }
    }
}
