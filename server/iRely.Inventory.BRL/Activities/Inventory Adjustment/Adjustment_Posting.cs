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

            // Pre-post validation
            if (isRecap == false && Adjustment.isPost)
            {
                // Check for outdated stock-on hand before the actual posting. 
                // If validation failed, auto-update any outdated on hand qty in the adjustment detail.                
                var validateResult = ValidateOutdatedStockOnHand(Adjustment.strTransactionId);
                if (validateResult.HasError) {
                    var updateResult = UpdateOutdatedStockOnHand(Adjustment.strTransactionId);
                    if (updateResult.HasError)
                        return updateResult;
                    else
                        return validateResult;
                }

                // Check for outdated expiry date before the actual posting. 
                // If validation failed, auto-update the outdated expiry dates in the adjustment detail. 
                validateResult = ValidateOutdatedExpiryDate(Adjustment.strTransactionId);
                if (validateResult.HasError)
                {
                    var updateResult = UpdateOutdatedExpiryDate(Adjustment.strTransactionId);
                    if (updateResult.HasError)
                        return updateResult;
                    else
                        return validateResult;
                }
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

        public SaveResult ValidateOutdatedStockOnHand(string transactionId)
        {
            // Post the Adjustment transaction 
            var validateResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.ValidateOutdatedStockOnHand(transactionId);
            }
            catch (Exception ex)
            {
                validateResult.BaseException = ex;
                validateResult.HasError = true;
                validateResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return validateResult;
        }

        public SaveResult UpdateOutdatedStockOnHand(string transactionId)
        {
            var updateResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.UpdateOutdatedStockOnHand(transactionId);
            }
            catch (Exception ex)
            {
                updateResult.BaseException = ex;
                updateResult.HasError = true;
                updateResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return updateResult;
        }

        public SaveResult ValidateOutdatedExpiryDate(string transactionId)
        {
            // Post the Adjustment transaction 
            var validateResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.ValidateOutdatedExpiryDate(transactionId);
            }
            catch (Exception ex)
            {
                validateResult.BaseException = ex;
                validateResult.HasError = true;
                validateResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return validateResult;
        }

        public SaveResult UpdateOutdatedExpiryDate(string transactionId)
        {
            var updateResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.UpdateOutdatedExpiryDate(transactionId);
            }
            catch (Exception ex)
            {
                updateResult.BaseException = ex;
                updateResult.HasError = true;
                updateResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return updateResult;
        }

    }
}
