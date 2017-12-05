﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryReceiptItemTaxBl : IBusinessLayer<tblICInventoryReceiptItemTax>
    {
        Task<SearchResult> GetReceiptItemTaxView(GetParameter param, int ReceiptItemId);
    }
}
