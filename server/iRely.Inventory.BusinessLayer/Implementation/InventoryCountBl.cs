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
    public class InventoryCountBl : BusinessLayer<tblICInventoryCount>, IInventoryCountBl 
    {
        #region Constructor
        public InventoryCountBl(IRepository db)
            : base(db)
        {
            _db = db;
            _db.ContextManager.Database.CommandTimeout = 120000;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryCount>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strcountno" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryCountId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strcountno" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryCountId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.Execute(param, "intInventoryCountId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICInventoryCount entity)
        {
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            entity.strCountNo = db.GetStartingNumber((int)Common.StartingNumber.InventoryCount, entity.intLocationId);
            base.Add(entity);
        }

        public async Task<SearchResult> GetCountSheets(GetParameter param, int CountId)
        {
            var query = _db.GetQuery<vyuICGetCountSheet>()
                .Where(p => p.intInventoryCountId == CountId)
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryCountId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public SaveResult LockInventory(int InventoryCountId, bool ysnLock)
        {
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.LockInventory(InventoryCountId, ysnLock);
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

        public SaveResult PostInventoryCount(Common.Posting_RequestModel count, bool isRecap)
        {
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
                if (count.isPost)
                {
                    db.PostInventoryCount(isRecap, count.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnPostInventoryCount(isRecap, count.strTransactionId, iRely.Common.Security.GetEntityId());
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

        /// <summary>
        /// Get Item Stock Summary
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemStockSummary(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStockSummary>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intKey").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Item Stock Summary By Lots
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemStockSummaryByLot(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStockSummaryByLot>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intKey").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetPrintVariance(GetParameter param, int CountId)
        {
            var query = _db.GetQuery<vyuICGetCountSheet>()
                .Where(p => p.intInventoryCountId == CountId && p.dblVariance != 0)
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryCountId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
