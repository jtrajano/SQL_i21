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
    public class LotController : ApiController
    {

        private Lot _LotBRL = new Lot();

        [HttpGet]
        public HttpResponseMessage SearchLots(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICLot>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICLot>(searchFilters);

            var data = _LotBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _LotBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetLots")]
        public HttpResponseMessage GetLots(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICLot>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intInventoryLotId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICLot>(searchFilters, true);

            var total = _LotBRL.GetCount(predicate);
            var data = _LotBRL.GetLots(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostLots(IEnumerable<tblICLot> lots, bool continueOnConflict = false)
        {
            foreach (var lot in lots)
                _LotBRL.AddLot(lot);

            var result = _LotBRL.Save(continueOnConflict);
            _LotBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lots,
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
        public HttpResponseMessage PutLots(IEnumerable<tblICLot> lots, bool continueOnConflict = false)
        {
            foreach (var lot in lots)
                _LotBRL.UpdateLot(lot);

            var result = _LotBRL.Save(continueOnConflict);
            _LotBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lots,
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
        public HttpResponseMessage DeleteLots(IEnumerable<tblICLot> lots, bool continueOnConflict = false)
        {
            foreach (var lot in lots)
                _LotBRL.DeleteLot(lot);

            var result = _LotBRL.Save(continueOnConflict);
            _LotBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lots,
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
