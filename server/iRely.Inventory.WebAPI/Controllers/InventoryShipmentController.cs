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
    public class InventoryShipmentController : BaseApiController<tblICInventoryShipment>
    {
        private IInventoryShipmentBl _bl;

        public InventoryShipmentController(IInventoryShipmentBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        public override Task<HttpResponseMessage> Post(IEnumerable<tblICInventoryShipment> entities, bool continueOnConflict = false)
        {
            _bl.SetUser(iRely.Common.Security.GetUserId());
            return base.Post(entities, continueOnConflict);
        }

        public override Task<HttpResponseMessage> Put(IEnumerable<tblICInventoryShipment> entities, bool continueOnConflict = false)
        {
            _bl.SetUser(iRely.Common.Security.GetUserId());
            return base.Put(entities, continueOnConflict);
        }

        public override Task<HttpResponseMessage> Delete(IEnumerable<tblICInventoryShipment> entities, bool continueOnConflict = false)
        {
            _bl.SetUser(iRely.Common.Security.GetUserId());
            return base.Delete(entities, continueOnConflict);
        }

        [HttpPost]
        public HttpResponseMessage Ship(BusinessLayer.Common.Posting_RequestModel shipment)
        {
            var result = _bl.PostTransaction(shipment, shipment.isRecap);

            if (result.HasError)
            {
                return Request.CreateResponse(HttpStatusCode.Conflict, new
                {
                    data = new
                    {
                        strBatchId = result.strBatchId,
                        strTransactionId = shipment.strTransactionId
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
                        strTransactionId = shipment.strTransactionId
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

        public struct ShipmentParam
        {
            public int id { get; set; }
        }

        [HttpPost]
        [ActionName("ProcessInvoice")]
        public HttpResponseMessage ProcessInvoice(ShipmentParam p)
        {
            int? newInvoice = null;
            var result = _bl.ProcessInvoice(p.id, out newInvoice);

            HttpStatusCode httpStatusCode = result.HasError ? HttpStatusCode.Conflict : HttpStatusCode.Accepted;            
            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    InvoiceId = newInvoice,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("SearchShipmentItems")]
        public async Task<HttpResponseMessage> SearchShipmentItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchShipmentItems(param));
        }

        [HttpGet]
        [ActionName("SearchShipmentInvoice")]
        public async Task<HttpResponseMessage> SearchShipmentInvoice(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchShipmentInvoice(param));
        }

        [HttpGet]
        [ActionName("SearchShipmentItemLots")]
        public async Task<HttpResponseMessage> SearchShipmentItemLots(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchShipmentItemLots(param));
        }

        [HttpGet]
        [ActionName("GetAddOrders")]
        public async Task<HttpResponseMessage> GetAddOrders(GetParameter param, int CustomerId, string OrderType, string SourceType)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAddOrders(param, CustomerId, OrderType, SourceType));
        }

        [HttpPost]
        [ActionName("CalculateCharges")]
        public HttpResponseMessage CalculateCharges(ShipmentParam p)
        {
            var result = _bl.CalculateCharges(p.id);

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
        [ActionName("GetCustomerCurrency")]
        public async Task<HttpResponseMessage> GetCustomerCurrency(GetParameter param, int? entityId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchCustomerCurrency(param, entityId));
        }

        [HttpPost]
        [ActionName("UpdateShipmentInvoice")]
        public HttpResponseMessage UpdateShipmentInvoice()
        {
            var result = _bl.UpdateShipmentInvoice();

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
    }
}
