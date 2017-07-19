using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStockUOMSummary
    {
        public int intKey { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblUnitQty { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblInConsigned { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblUnitReserved { get; set; }
        public decimal? dblInTransitInbound { get; set; }
        public decimal? dblInTransitOutbound { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblConsignedPurchase { get; set; }
        public decimal? dblConsignedSale { get; set; }
    }
}
