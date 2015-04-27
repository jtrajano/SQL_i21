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
    public partial class Adjustment : IDisposable
    {
        public SaveResult PostTransaction(Inventory.BRL.Common.Posting_RequestModel Adjustment, bool isRecap)
        {
            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                return result;
            }

            // Post the Adjustment transaction 
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                if (Adjustment.isPost)
                {
                    db.PostInventoryAdjustment(isRecap, Adjustment.strTransactionId, iRely.Common.Security.GetUserId(), 1);
                }
                else
                {
                    db.UnPostInventoryAdjustment(isRecap, Adjustment.strTransactionId, iRely.Common.Security.GetUserId(), 1);
                }
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
    }
}
