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
        public InventoryAdjustmentBl(IInventoryRepository db) : base(db)
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

            var data = await query.ExecuteProjection(param, "intInventoryAdjustmentId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
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
            
            var data = await query.ExecuteProjection(param, "intInventoryAdjustmentDetailId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override async Task<GetObjectResult> GetAsync(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryAdjustment>().Filter(param, true);
            var key = Methods.GetPrimaryKey<vyuICGetInventoryAdjustment>(_db.ContextManager);

            return new GetObjectResult()
            {
                data = await query.Execute(param, key).ToListAsync(param.cancellationToken).ConfigureAwait(false),
                total = await query.CountAsync().ConfigureAwait(false)
            };
        }

        public async Task<GetObjectResult> GetAdjustmentDetails(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryAdjustmentDetail>().Filter(param, true);
            var key = Methods.GetPrimaryKey<vyuICGetInventoryAdjustmentDetail>(_db.ContextManager);

            return new GetObjectResult()
            {
                data = await query.Execute(param, key).ToListAsync(param.cancellationToken).ConfigureAwait(false),
                total = await query.CountAsync()
            };
        }

        public override void Add(tblICInventoryAdjustment entity)
        {
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            entity.strAdjustmentNo = db.GetStartingNumber((int)Common.StartingNumber.InventoryAdjustment, entity.intLocationId);
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public Common.GLPostResult PostTransaction(Common.Posting_RequestModel Adjustment, bool isRecap)
        {
            var glPostResult = new Common.GLPostResult();
            glPostResult.Exception = new ServerException();

            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                glPostResult.BaseException = result.BaseException;
                glPostResult.Exception = result.Exception;
                glPostResult.HasError = result.HasError;
                glPostResult.RowsAffected = result.RowsAffected;
                //glPostResult.strBatchId = null; 

                return glPostResult;
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
                    {
                        glPostResult.BaseException = updateResult.BaseException;
                        glPostResult.Exception = updateResult.Exception;
                        glPostResult.HasError = updateResult.HasError;
                        glPostResult.RowsAffected = updateResult.RowsAffected;

                        return glPostResult;
                    }
                    else
                    {
                        glPostResult.BaseException = validateResult.BaseException;
                        glPostResult.Exception = validateResult.Exception;
                        glPostResult.HasError = validateResult.HasError;
                        glPostResult.RowsAffected = validateResult.RowsAffected;

                        return glPostResult;
                    }
                }

                // Check for outdated expiry date before the actual posting. 
                // If validation failed, auto-update the outdated expiry dates in the adjustment detail. 
                validateResult = ValidateOutdatedExpiryDate(Adjustment.strTransactionId);
                if (validateResult.HasError)
                {
                    var updateResult = UpdateOutdatedExpiryDate(Adjustment.strTransactionId);
                    if (updateResult.HasError)
                    {
                        glPostResult.BaseException = updateResult.BaseException;
                        glPostResult.Exception = updateResult.Exception;
                        glPostResult.HasError = updateResult.HasError;
                        glPostResult.RowsAffected = updateResult.RowsAffected;

                        return glPostResult;
                    }
                    else
                    {
                        glPostResult.BaseException = validateResult.BaseException;
                        glPostResult.Exception = validateResult.Exception;
                        glPostResult.HasError = validateResult.HasError;
                        glPostResult.RowsAffected = validateResult.RowsAffected;

                        return glPostResult;
                    }
                }
            }

            // Post the Adjustment transaction 
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                string strBatchId;
                if (Adjustment.isPost)
                {
                    strBatchId = db.PostInventoryAdjustment(isRecap, Adjustment.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    strBatchId = db.UnPostInventoryAdjustment(isRecap, Adjustment.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                glPostResult.HasError = false;
                glPostResult.strBatchId = strBatchId;
            }
            catch (Exception ex)
            {
                glPostResult.BaseException = ex;
                glPostResult.HasError = true;
                glPostResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return glPostResult;
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
            var data = await query.ExecuteProjection(param, "intLotId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
