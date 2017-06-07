using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Data.SqlClient;
using System.Data.Entity;

namespace iRely.Inventory.WebApi
{
    public class InventoryCountController : BaseApiController<tblICInventoryCount>
    {
        private IInventoryCountBl _bl;

        public InventoryCountController(IInventoryCountBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetCountSheets(GetParameter param, int CountId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetCountSheets(param, CountId));
        }

        public class InvCountDetailsParams
        {
            public int intInventoryCountId { get; set; }
            public int intEntityUserSecurityId { get; set; }
            public string strHeaderNo { get; set; }
            public int intLocationId { get; set; }
            public int intCategoryId { get; set; }
            public int intCommodityId { get; set; }
            public int intCountGroupId { get; set; }
            public int intSubLocationId { get; set; }
            public int intStorageLocationId { get; set; }
            public bool ysnIncludeZeroOnHand { get; set; }
            public bool ysnCountByLots { get; set; }
        }

        [HttpPut]
        [ActionName("UpdateDetails")]
        public async Task<HttpResponseMessage> UpdateDetails([FromBody] InvCountDetailsParams param)
        {
            var updateResult = new SaveResult();
            try
            {
                var db = ((InventoryCountBl)_bl).GetRepository().ContextManager.Database;
                var query = (@"EXEC dbo.uspICUpdateInventoryCountDetails
	                              @intInventoryCountId, @intEntityUserSecurityId, @strHeaderNo, @intLocationId
                                , @intCategoryId, @intCommodityId, @intCountGroupId
	                            , @intSubLocationId, @intStorageLocationId, @ysnIncludeZeroOnHand, @ysnCountByLots");
                await db.ExecuteSqlCommandAsync(query,
                    new SqlParameter("@intInventoryCountId", param.intInventoryCountId),
                    new SqlParameter("@intEntityUserSecurityId", param.intEntityUserSecurityId),
                    new SqlParameter("@strHeaderNo", param.strHeaderNo),
                    new SqlParameter("@intLocationId", param.intLocationId),
                    new SqlParameter("@intCategoryId", param.intCategoryId),
                    new SqlParameter("@intCommodityId", param.intCommodityId),
                    new SqlParameter("@intCountGroupId", param.intCountGroupId),
                    new SqlParameter("@intSubLocationId", param.intSubLocationId),
                    new SqlParameter("@intStorageLocationId", param.intStorageLocationId),
                    new SqlParameter("@ysnIncludeZeroOnHand", param.ysnIncludeZeroOnHand),
                    new SqlParameter("@ysnCountByLots", param.ysnCountByLots));
                updateResult.HasError = false;
            }
            catch (Exception ex)
            {
                updateResult.BaseException = ex;
                updateResult.HasError = true;
                updateResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }

            return Request.CreateResponse(updateResult.HasError ? HttpStatusCode.InternalServerError : HttpStatusCode.Accepted, updateResult);
        }

        [HttpGet]
        [ActionName("GetInventoryCountDetails")]
        public async Task<HttpResponseMessage> GetInventoryCountDetails(GetParameter param)
        {
            var result = new SearchResult();
            var query = ((InventoryCountBl)_bl).GetRepository().GetQuery<vyuICGetInventoryCountDetail>()
                    .Filter(param, true);
            try
            {
                var data = await query.Execute(param, "intInventoryCountDetailId").ToListAsync();

                result = new SearchResult()
                {
                    data = data.AsQueryable(),
                    success = true,
                    total = await query.CountAsync(),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            catch(Exception ex)
            {
                result = new SearchResult()
                {
                    success = false,
                    summaryData = ex.Message
                };
            }

            return Request.CreateResponse(result.success ? HttpStatusCode.Accepted : HttpStatusCode.InternalServerError, result);
        }


        public struct LockInventoryCount
        {
            public int intInventoryCountId { get; set; }
            public bool ysnLock { get; set; }
        }

        [HttpPost]
        [ActionName("LockInventory")]
        public HttpResponseMessage LockInventory([FromBody]LockInventoryCount lockIC)
        {
            var result = _bl.LockInventory(lockIC.intInventoryCountId, lockIC.ysnLock);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lockIC,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpPost]
        [ActionName("PostTransaction")]
        public HttpResponseMessage PostTransaction(BusinessLayer.Common.Posting_RequestModel count)
        {
            var result = _bl.PostInventoryCount(count, count.isRecap);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = count,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("SearchItemStockSummary")]
        public async Task<HttpResponseMessage> SearchItemStockSummary(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockSummary(param));
        }

        [HttpGet]
        [ActionName("GetItemStockSummaryByLot")]
        public async Task<HttpResponseMessage> GetItemStockSummaryByLot(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockSummaryByLot(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetPrintVariance(GetParameter param, int CountId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetPrintVariance(param, CountId));
        }
    }
}
