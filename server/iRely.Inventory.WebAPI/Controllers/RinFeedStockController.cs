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
    public class RinFeedStockController : ApiController
    {
        private RinFeedStock _RinFeedStockBRL = new RinFeedStock();

        [HttpGet]
        public HttpResponseMessage SearchRinFeedStocks(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFeedStock>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFeedStock>(searchFilters);

            var data = _RinFeedStockBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _RinFeedStockBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRinFeedStocks")]
        public HttpResponseMessage GetRinFeedStocks(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFeedStock>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRinFeedStockId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFeedStock>(searchFilters, true);

            var total = _RinFeedStockBRL.GetCount(predicate);
            var data = _RinFeedStockBRL.GetRinFeedStocks(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostRinFeedStocks(IEnumerable<tblICRinFeedStock> RinFeedStocks, bool continueOnConflict = false)
        {
            foreach (var RinFeedStock in RinFeedStocks)
                _RinFeedStockBRL.AddRinFeedStock(RinFeedStock);

            var result = _RinFeedStockBRL.Save(continueOnConflict);
            _RinFeedStockBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFeedStocks,
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
        public HttpResponseMessage PutRinFeedStocks(IEnumerable<tblICRinFeedStock> RinFeedStocks, bool continueOnConflict = false)
        {
            foreach (var RinFeedStock in RinFeedStocks)
                _RinFeedStockBRL.UpdateRinFeedStock(RinFeedStock);

            var result = _RinFeedStockBRL.Save(continueOnConflict);
            _RinFeedStockBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFeedStocks,
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
        public HttpResponseMessage DeleteRinFeedStocks(IEnumerable<tblICRinFeedStock> RinFeedStocks, bool continueOnConflict = false)
        {
            foreach (var RinFeedStock in RinFeedStocks)
                _RinFeedStockBRL.DeleteRinFeedStock(RinFeedStock);

            var result = _RinFeedStockBRL.Save(continueOnConflict);
            _RinFeedStockBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFeedStocks,
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
