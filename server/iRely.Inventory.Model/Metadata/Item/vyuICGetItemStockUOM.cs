using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStockUOM
    {
        public int intItemStockUOMId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strType { get; set; }
        public string strBundleType { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public string strLotTracking { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public string strLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblReservedQty { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public decimal? dblStorageQty { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool? ysnStockUnit { get; set; }
        public decimal? dblStockUnitCost { get; set; }
        public decimal? dblLastCost { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
    }
}
