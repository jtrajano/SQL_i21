﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemPricingBl : IBusinessLayer<tblICItemPricing>
    {
        Task<SearchResult> GetItemPricingViews(GetParameter param);


    }

    public interface IItemPricingLevelBl : IBusinessLayer<tblICItemPricingLevel>
    {
        
    }

    public interface IItemSpecialPricingBl : IBusinessLayer<tblICItemSpecialPricing>
    {
        
    }
}
