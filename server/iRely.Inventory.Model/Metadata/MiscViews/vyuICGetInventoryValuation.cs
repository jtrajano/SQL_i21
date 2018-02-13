using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryValuation
    {
        public int intInventoryValuationKeyId { get; set; }
        public int? intInventoryTransactionId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public DateTime? dtmDate { get; set; }
        public string strTransactionType { get; set; }
        public string strTransactionForm { get; set; }
        public string strTransactionId { get; set; }
        public decimal? dblBeginningQtyBalance { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblRunningQtyBalance { get; set; }
        public decimal? dblCost { get; set; }
        public decimal? dblBeginningBalance { get; set; }
        public decimal? dblValue { get; set; }
        public decimal? dblRunningBalance { get; set; }
        public string strBatchId { get; set; }
        public string strCostingMethod { get; set; }
        public string strUOM { get; set; }
        public string strStockUOM { get; set; }
        public decimal? dblQuantityInStockUOM { get; set; }
        public decimal? dblCostInStockUOM { get; set; }
        public string strBOLNumber { get; set; }
        public string strEntity { get; set; }
        public string strLotNumber { get; set; }
        public string strAdjustedTransaction { get; set; }
        public bool? ysnInTransit { get; set; }
    }
}
