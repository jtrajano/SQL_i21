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
    public class InventoryTransferBl : BusinessLayer<tblICInventoryTransfer>, IInventoryTransferBl 
    {
        #region Constructor
        public InventoryTransferBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryTransfer>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strtransferno" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryTransferId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strtransferno" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryTransferId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryTransferId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICInventoryTransfer entity)
        {
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            entity.strTransferNo = db.GetStartingNumber((int)Common.StartingNumber.InventoryTransfer, entity.intFromLocationId);
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public async Task<Common.GLPostResult> PostTransaction(Common.Posting_RequestModel Transfer, bool isRecap)
        {
            // Save the record first 
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
                glPostResult.strBatchId = null;

                return glPostResult;
            }

            // Post the Adjustment transaction 
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                string strBatchId; 
                if (Transfer.isPost)
                {
                    strBatchId = await db.PostInventoryTransfer(isRecap, Transfer.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    strBatchId = await db.UnPostInventoryTransfer(isRecap, Transfer.strTransactionId, iRely.Common.Security.GetEntityId());
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

        public async Task<SearchResult> SearchTransferDetails(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryTransferDetail>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strtransferno" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryTransferId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strtransferno" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryTransferId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryTransferDetailId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
