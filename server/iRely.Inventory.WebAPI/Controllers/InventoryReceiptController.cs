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
    public class InventoryReceiptController : BaseApiController<tblICInventoryReceipt>
    {
        private IInventoryReceiptBl _bl;

        public InventoryReceiptController(IInventoryReceiptBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        public override System.Threading.Tasks.Task<HttpResponseMessage> Post(IEnumerable<tblICInventoryReceipt> entities, bool continueOnConflict = false)
        {
            _bl.SetUser(iRely.Common.Security.GetUserId());
            return base.Post(entities, continueOnConflict);
        }

        public override System.Threading.Tasks.Task<HttpResponseMessage> Put(IEnumerable<tblICInventoryReceipt> entities, bool continueOnConflict = false)
        {
            _bl.SetUser(iRely.Common.Security.GetUserId());
            return base.Put(entities, continueOnConflict);
        }

        public override System.Threading.Tasks.Task<HttpResponseMessage> Delete(IEnumerable<tblICInventoryReceipt> entities, bool continueOnConflict = false)
        {
            _bl.SetUser(iRely.Common.Security.GetUserId());
            return base.Delete(entities, continueOnConflict);
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

        [HttpPost]
        [ActionName("CalculateCharges")]
        public HttpResponseMessage CalculateCharges(int id)
        {
            var result = _bl.CalculateCharges(id);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
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
        [ActionName("UpdateReceiptInspection")]
        public HttpResponseMessage UpdateReceiptInspection(int id)
        {
            var result = _bl.UpdateReceiptInspection(id);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
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
        [ActionName("SearchReceiptItems")]
        public async Task<HttpResponseMessage> SearchReceiptItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchReceiptItems(param));
        }

        [HttpGet]
        [ActionName("SearchReceiptItemView")]
        public async Task<HttpResponseMessage> SearchReceiptItemView(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchReceiptItemView(param));
        }

        [HttpGet]
        [ActionName("SearchReceiptItemLots")]
        public async Task<HttpResponseMessage> SearchReceiptItemLots(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchReceiptItemLots(param));
        }

        [HttpGet]
        [ActionName("GetAddOrders")]
        public async Task<HttpResponseMessage> GetAddOrders(GetParameter param, int VendorId, string ReceiptType, int SourceType, int CurrencyId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAddOrders(param, VendorId, ReceiptType, SourceType, CurrencyId));
        }

        [HttpGet]
        [ActionName("GetReceiptVouchers")]
        public async Task<HttpResponseMessage> GetReceiptVouchers(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetReceiptVouchers(param));
        }
    }
}
