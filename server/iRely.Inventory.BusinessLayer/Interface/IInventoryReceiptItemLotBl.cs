using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryReceiptItemLotBl : IBusinessLayer<tblICInventoryReceiptItemLot>
    {
        Task<SearchResult> SearchLots(GetParameter param);
    }
}
