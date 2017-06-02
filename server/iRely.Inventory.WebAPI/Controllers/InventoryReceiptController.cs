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
            var result = _bl.PostReceive(receipt, receipt.isRecap);

            var httpStatusCode = result.HasError ? HttpStatusCode.Conflict : HttpStatusCode.Accepted;
            return Request.CreateResponse(httpStatusCode, new
            {
                data = new
                {
                    strBatchId = result.strBatchId,
                    strTransactionId = receipt.strTransactionId
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

        [HttpPost]
        [ActionName("Return")]
        public HttpResponseMessage Return(BusinessLayer.Common.Posting_RequestModel receipt)
        {
            var result = _bl.PostReturn(receipt, receipt.isRecap);

            if (result.HasError)
            {
                return Request.CreateResponse(HttpStatusCode.Conflict, new
                {
                    data = new
                    {
                        strBatchId = result.strBatchId,
                        strTransactionId = receipt.strTransactionId
                    },
                    success = false,
                    message = new
                    {
                        statusText = result.Exception.Message,
                        status = result.Exception.Error,
                        button = result.Exception.Button.ToString()
                    }
                });
            }
            else
            {
                return Request.CreateResponse(HttpStatusCode.Accepted, new
                {
                    data = new
                    {
                        strBatchId = result.strBatchId,
                        strTransactionId = receipt.strTransactionId
                    },
                    success = true,
                    message = new
                    {
                        statusText = result.Exception.Message,
                        status = result.Exception.Error,
                        button = result.Exception.Button.ToString()
                    }
                });
            }
        }

        [HttpGet]
        [ActionName("ProcessBill")]
        public HttpResponseMessage ProcessBill(int id)
        {
            int? newBill = null;
            string newBillIds = string.Empty;
            var result = _bl.ProcessBill(id, out newBill, out newBillIds);

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    BillId = newBill,
                    BillIds = newBillIds,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("CalculateCharges")]
        public HttpResponseMessage CalculateCharges(int id)
        {
            var result = _bl.CalculateCharges(id);

            var httpStatusCode = HttpStatusCode.OK; 
            if (result.HasError) httpStatusCode = HttpStatusCode.InternalServerError;            

            return Request.CreateResponse(httpStatusCode, new
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
        [ActionName("UpdateReceiptInspection")]
        public HttpResponseMessage UpdateReceiptInspection(int id)
        {
            var result = _bl.UpdateReceiptInspection(id);

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
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
        [ActionName("GetTaxGroupId")]
        public HttpResponseMessage GetTaxGroupId(int id)
        {
            int? taxGroup = null;
            string taxGroupName = null;
            var result = _bl.GetTaxGroupId(id, out taxGroup, out taxGroupName);

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    taxGroupId = taxGroup,
                    taxGroupN = taxGroupName,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("GetDefaultReceiptTaxGroupId")]
        public HttpResponseMessage GetDefaultReceiptTaxGroupId(int? freightTermId, int? locationId, int? entityVendorId, int? entityLocationId)
        {
            int? taxGroup = null;
            string taxGroupName = null;
            var result = _bl.GetDefaultReceiptTaxGroupId(freightTermId, locationId, entityVendorId, entityLocationId, out taxGroup, out taxGroupName);

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    taxGroupId = taxGroup,
                    taxGroupN = taxGroupName,
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
        [ActionName("SearchReceiptVouchers")]
        public async Task<HttpResponseMessage> SearchReceiptVouchers(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchReceiptVouchers(param));
        }

        [HttpGet]
        [ActionName("GetChargeTaxDetails")]
        public async Task<HttpResponseMessage> GetChargeTaxDetails(GetParameter param, int ChargeId, int ReceiptId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetChargeTaxDetails(param, ChargeId, ReceiptId));
        }

        [HttpGet]
        [ActionName("GetStatusUnitCost")]
        public HttpResponseMessage GetStatusUnitCost(int id)
        {
            int? newStatus = null;
            var result = _bl.GetStatusUnitCost(id, out newStatus);

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    receiptItemsStatusId = newStatus,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("ReturnReceipt")]
        public HttpResponseMessage ReturnReceipt(int id)
        {
            int? inventoryReturnId = null;
            var result = _bl.ReturnReceipt(id, out inventoryReturnId);

            var httpStatusCode = result.HasError ? HttpStatusCode.Conflict : HttpStatusCode.OK;
            return Request.CreateResponse(httpStatusCode, new
            {
                success = result.HasError ? false : true,
                message = new
                {
                    InventoryReturnId = inventoryReturnId,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("SearchReceiptCharges")]
        public async Task<HttpResponseMessage> SearchReceiptCharges(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchReceiptCharges(param));
        }

        [HttpPost]
        [ActionName("UpdateReceiptVoucher")]
        public HttpResponseMessage UpdateReceiptVoucher()
        {
            var result = _bl.UpdateReceiptVoucher();

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
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
        [ActionName("CheckReceiptForValidReturn")]
        public HttpResponseMessage CheckReceiptForValidReturn(int? receiptId)
        {
            var result = _bl.CheckReceiptForValidReturn(receiptId);

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.NotAcceptable;

            return Request.CreateResponse(httpStatusCode, new
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

    }
}
