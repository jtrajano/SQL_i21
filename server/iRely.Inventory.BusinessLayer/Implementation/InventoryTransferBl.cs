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

        public SaveResult PostTransaction(Common.Posting_RequestModel Transfer, bool isRecap)
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
                if (Transfer.isPost)
                {
                    db.PostInventoryTransfer(isRecap, Transfer.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnPostInventoryTransfer(isRecap, Transfer.strTransactionId, iRely.Common.Security.GetEntityId());
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
