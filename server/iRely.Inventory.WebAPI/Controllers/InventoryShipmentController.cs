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
        [ActionName("ShipmentInvoice")]
        public async Task<HttpResponseMessage> ShipmentInvoice(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.ShipmentInvoice(param));
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
        public async Task<HttpResponseMessage> GetCustomerCurrency(int customerId)
        {
            InventoryRepository repo = new InventoryRepository();
            var query = @"  SELECT c.intEntityCustomerId, c.strCustomerNumber, c.intCurrencyId, cr.strCurrency, cr.strDescription, cr.ysnSubCurrency, cr.intMainCurrencyId, cr.intCent
                            FROM tblARCustomer c
                                INNER JOIN tblSMCurrency cr ON cr.intCurrencyID = c.intCurrencyId
                            WHERE c.intEntityCustomerId = @customerId";
            System.Data.SqlClient.SqlParameter p = new System.Data.SqlClient.SqlParameter("@customerId", customerId);
            p.SqlDbType = System.Data.SqlDbType.Int;
            var ctx = repo.ContextManager.Database.SqlQuery<Customer>(query, new object[] { p });
            var customer = await ctx.ToListAsync();
            return Request.CreateResponse(HttpStatusCode.OK, customer.AsQueryable());
        }
    }

    class Customer
    {
        public int intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public int intCurrencyId { get; set; }
        public string strCurrency { get; set; }
    }
}
