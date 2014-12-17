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
    public class ItemStockController : ApiController
    {
        private ItemStock _ItemStockBRL = new ItemStock();

        [HttpGet]
        public HttpResponseMessage SearchItemStocks(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemStock>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemStock>(searchFilters);

            var data = _ItemStockBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemStockBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemStocks")]
        public HttpResponseMessage GetItemStocks(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemStock>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemStockId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemStock>(searchFilters, true);

            var total = _ItemStockBRL.GetCount(predicate);
            var data = _ItemStockBRL.GetItemStocks(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemStocks(IEnumerable<tblICItemStock> stocks, bool continueOnConflict = false)
        {
            foreach (var stock in stocks)
                _ItemStockBRL.AddItemStock(stock);

            var result = _ItemStockBRL.Save(continueOnConflict);
            _ItemStockBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = stocks,
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
        public HttpResponseMessage PutItemStocks(IEnumerable<tblICItemStock> stocks, bool continueOnConflict = false)
        {
            foreach (var stock in stocks)
                _ItemStockBRL.UpdateItemStock(stock);

            var result = _ItemStockBRL.Save(continueOnConflict);
            _ItemStockBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = stocks,
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
        public HttpResponseMessage DeleteItemStocks(IEnumerable<tblICItemStock> stocks, bool continueOnConflict = false)
        {
            foreach (var stock in stocks)
                _ItemStockBRL.DeleteItemStock(stock);

            var result = _ItemStockBRL.Save(continueOnConflict);
            _ItemStockBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = stocks,
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
