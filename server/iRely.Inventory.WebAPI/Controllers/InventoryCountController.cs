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
