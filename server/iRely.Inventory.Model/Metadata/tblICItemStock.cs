using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemStock : BaseEntity
    {
        public int intItemStockId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblInTransitInbound { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblInTransitOutbound { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblConsignedPurchase { get; set; }
        public decimal? dblConsignedSale { get; set; }
        public decimal? dblUnitReserved { get; set; }
        public decimal? dblLastCountRetail { get; set; }
        public int? intSort { get; set; }
        public string strUnitMeasure { get; set; }
        public string strLocationName { get; set; }

        public tblICItem tblICItem { get; set; }
    }

    public class ItemStockVM
    {
        public int intItemStockId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblUnitInConsigned { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblLastCountRetail { get; set; }
        
        public string strItemNo { get; set; }
        public string strLocationName { get; set; }
        public string strSubLocationName { get; set; }

    }
}
