using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

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
        public HttpResponseMessage PostTransaction(BusinessLayer.Common.Posting_RequestModel transfer)
        {
            var result = _bl.PostTransaction(transfer, transfer.isRecap);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = transfer,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

    }
}
