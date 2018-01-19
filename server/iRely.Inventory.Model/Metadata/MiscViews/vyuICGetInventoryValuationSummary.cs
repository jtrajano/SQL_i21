﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryValuationSummary
    {
        public int intInventoryValuationKeyId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public DateTime? dtmDate { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblValue { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblQuantityInStockUOM { get; set; }
        public string strStockUOM { get; set; }
        public string strCategoryCode { get; set; }
        public string strCommodityCode { get; set; }
        public string strInTransitLocationName { get; set; }
        public int? intLocationId { get; set; }
        public int? intInTransitLocationId { get; set; }
    }
}
