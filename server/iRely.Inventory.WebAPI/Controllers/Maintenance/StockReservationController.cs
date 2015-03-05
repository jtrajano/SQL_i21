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
    public class StockReservationController : ApiController
    {
         private StockReservation _StockReservationBRL = new StockReservation();

        [HttpGet]
        public HttpResponseMessage SearchStockReservations(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStockReservation>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStockReservation>(searchFilters);

            var data = _StockReservationBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _StockReservationBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetStockReservations")]
        public HttpResponseMessage GetStockReservations(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStockReservation>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intStockReservationId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStockReservation>(searchFilters, true);

            var total = _StockReservationBRL.GetCount(predicate);
            var data = _StockReservationBRL.GetStockReservations(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostStockReservations(IEnumerable<tblICStockReservation> reservations, bool continueOnConflict = false)
        {
            foreach (var reservation in reservations)
                _StockReservationBRL.AddStockReservation(reservation);

            var result = _StockReservationBRL.Save(continueOnConflict);
            _StockReservationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = reservations,
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
        public HttpResponseMessage PutStockReservations(IEnumerable<tblICStockReservation> reservations, bool continueOnConflict = false)
        {
            foreach (var reservation in reservations)
                _StockReservationBRL.UpdateStockReservation(reservation);

            var result = _StockReservationBRL.Save(continueOnConflict);
            _StockReservationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = reservations,
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
        public HttpResponseMessage DeleteStockReservations(IEnumerable<tblICStockReservation> reservations, bool continueOnConflict = false)
        {
            foreach (var reservation in reservations)
                _StockReservationBRL.DeleteStockReservation(reservation);

            var result = _StockReservationBRL.Save(continueOnConflict);
            _StockReservationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = reservations,
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
