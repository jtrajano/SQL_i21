﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemStockBl : IBusinessLayer<tblICItemStock>
    {
        Task<SearchResult> GetItemStockUOMView(GetParameter param);
        Task<SearchResult> GetItemStockUOMViewTotals(GetParameter param);
        Task<SearchResult> GetLocationStockOnHand(int intLocationId, int intItemId);
        Task<SearchResult> GetItemStockUOMForAdjustmentView(GetParameter param);
    }
}
