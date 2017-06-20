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
    public class InventoryTransferController : BaseApiController<tblICInventoryTransfer>
    {
        private IInventoryTransferBl _bl;

        public InventoryTransferController(IInventoryTransferBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpPost]
        public async Task<HttpResponseMessage> PostTransaction(BusinessLayer.Common.Posting_RequestModel transfer)
        {
            var result = await _bl.PostTransaction(transfer, transfer.isRecap);

            var httpStatusCode = result.HasError ? HttpStatusCode.Conflict : HttpStatusCode.Accepted;
            return Request.CreateResponse(httpStatusCode, new
            {
                data = new
                {
                    strBatchId = result.strBatchId,
                    strTransactionId = transfer.strTransactionId
                },
                success = result.HasError ? false : true,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("SearchTransferDetails")]
        public async Task<HttpResponseMessage> SearchTransferDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchTransferDetails(param));
        }

    }
}
