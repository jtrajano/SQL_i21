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
        public SaveResult PostTransaction(Inventory.BRL.Common.Posting_RequestModel receipt, bool isRecap)
        {
            // TODO for Lawrence
            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                return result;
            }

            // Post the receipt transaction 
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.PostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetUserId(), 1);

                postResult.HasError = false;
            }
            catch (Exception ex)
            {
                postResult.BaseException = ex;
                postResult.HasError = true;
                postResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return postResult;
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
