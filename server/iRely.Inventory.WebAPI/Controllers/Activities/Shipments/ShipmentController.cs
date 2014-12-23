using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using Newtonsoft.Json;
using IdeaBlade.Core;
using IdeaBlade.Linq;

using iRely.Common;
using iRely.Inventory.Model;
using iRely.Inventory.BRL;

namespace iRely.Invetory.WebAPI.Controllers
{
    public class ShipmentController : ApiController
    {
         private Shipment _ShipmentBRL = new Shipment();

        [HttpGet]
        public HttpResponseMessage SearchShipments(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<InventoryShipmentView>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<InventoryShipmentView>(searchFilters);

            var data = _ShipmentBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ShipmentBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetShipments")]
        public HttpResponseMessage GetShipments(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<InventoryShipmentView>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intInventoryShipmentId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<InventoryShipmentView>(searchFilters, true);

            var total = _ShipmentBRL.GetCount(predicate);
            var data = _ShipmentBRL.GetShipments(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostShipments(IEnumerable<tblICInventoryShipment> shipments, bool continueOnConflict = false)
        {
            foreach (var shipment in shipments)
                _ShipmentBRL.AddShipment(shipment);

            var result = _ShipmentBRL.Save(continueOnConflict);
            _ShipmentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = shipments,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpPut]
        public HttpResponseMessage PutShipments(IEnumerable<tblICInventoryShipment> shipments, bool continueOnConflict = false)
        {
            foreach (var shipment in shipments)
                _ShipmentBRL.UpdateShipment(shipment);

            var result = _ShipmentBRL.Save(continueOnConflict);
            _ShipmentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = shipments,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpDelete]
        public HttpResponseMessage DeleteShipments(IEnumerable<tblICInventoryShipment> shipments, bool continueOnConflict = false)
        {
            foreach (var shipment in shipments)
                _ShipmentBRL.DeleteShipment(shipment);

            var result = _ShipmentBRL.Save(continueOnConflict);
            _ShipmentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = shipments,
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
