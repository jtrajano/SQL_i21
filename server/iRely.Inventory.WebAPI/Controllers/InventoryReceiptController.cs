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
    public class InventoryReceiptController : BaseApiController<tblICInventoryReceipt>
    {
        private IInventoryReceiptBl _bl;

        public InventoryReceiptController(IInventoryReceiptBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpPost]
        [ActionName("Receive")]
        public HttpResponseMessage Receive(BusinessLayer.Common.Posting_RequestModel receipt)
        {
            var result = _bl.PostTransaction(receipt, receipt.isRecap);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = receipt,
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
        [ActionName("ProcessBill")]
        public HttpResponseMessage ProcessBill(int id)
        {
            int? newBill = null;
            var result = _bl.ProcessBill(id, out newBill);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                success = !result.HasError,
                message = new
                {
                    BillId = newBill,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }
    }
}
