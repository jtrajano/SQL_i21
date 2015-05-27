using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryTransferBl : IBusinessLayer<tblICInventoryTransfer>
    {
        SaveResult PostTransaction(Common.Posting_RequestModel Transfer, bool isRecap);
    }
}
