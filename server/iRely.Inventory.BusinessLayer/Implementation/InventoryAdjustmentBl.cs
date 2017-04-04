using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryAdjustmentBl : BusinessLayer<tblICInventoryAdjustment>, IInventoryAdjustmentBl 
    {
        #region Constructor
        public InventoryAdjustmentBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryAdjustment>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "stradjustmentno" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryAdjustmentId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "stradjustmentno" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryAdjustmentId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryAdjustmentId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchAdjustmentDetails(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryAdjustmentDetail>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "stradjustmentno" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryAdjustmentId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "stradjustmentno" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryAdjustmentId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;
            
            var data = await query.ExecuteProjection(param, "intInventoryAdjustmentDetailId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICInventoryAdjustment entity)
        {
            entity.strAdjustmentNo = Common.GetStartingNumber(Common.StartingNumber.InventoryAdjustment);
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public SaveResult PostTransaction(Common.Posting_RequestModel Adjustment, bool isRecap)
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
                if (validateResult.HasError)
                {
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
                    db.PostInventoryAdjustment(isRecap, Adjustment.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnPostInventoryAdjustment(isRecap, Adjustment.strTransactionId, iRely.Common.Security.GetEntityId());
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

        private SaveResult ValidateOutdatedStockOnHand(string transactionId)
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

        private SaveResult UpdateOutdatedStockOnHand(string transactionId)
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

        private SaveResult ValidateOutdatedExpiryDate(string transactionId)
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

        private SaveResult UpdateOutdatedExpiryDate(string transactionId)
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

        public async Task<SearchResult> SearchPostedLots(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetPostedLot>()
                           .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intLotId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
