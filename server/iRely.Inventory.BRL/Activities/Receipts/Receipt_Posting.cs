using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Web;

using iRely.Common;
using iRely.Inventory.Model;
using IdeaBlade.Core;
using IdeaBlade.Linq;

namespace iRely.Inventory.BRL
{
    public partial class Receipt : IDisposable
    {
        public void PostTransaction(tblICInventoryReceipt receipt, bool isRecap)
        {
            // TODO for Lawrence
            // Save the record first 


            // Post the receipt transaction 
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            db.PostInventoryReceipt(isRecap, receipt.strReceiptNumber, iRely.Common.Security.GetUserId(), iRely.Common.Security.GetEntityId()); 
        }

        public void UnpostTransaction(string transaction, bool isRecap)
        {
            // TODO for Lawrence
            // Save the record first 


            // TODO for Feb
            // Call the unpost routine 
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            // TODO: Call the unpost routine 
        }
    }
}
