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

        [HttpPost]
        public HttpResponseMessage Ship(BusinessLayer.Common.Posting_RequestModel shipment)
        {
            var result = _bl.PostTransaction(shipment, shipment.isRecap);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = shipment,
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
        [ActionName("ProcessInvoice")]
        public HttpResponseMessage ProcessInvoice(int id)
        {
            int? newInvoice = null;
            var result = _bl.ProcessInvoice(id, out newInvoice);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
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

    }
}
