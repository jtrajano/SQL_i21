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
    public class ItemCommodityCostController : ApiController
    {
         private ItemCommodityCost _ItemCommodityCostBRL = new ItemCommodityCost();

        [HttpGet]
        public HttpResponseMessage SearchItemCommodityCosts(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemCommodityCost>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemCommodityCost>(searchFilters);

            var data = _ItemCommodityCostBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemCommodityCostBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemCommodityCosts")]
        public HttpResponseMessage GetItemCommodityCosts(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemCommodityCost>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemCommodityCostId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemCommodityCost>(searchFilters, true);

            var total = _ItemCommodityCostBRL.GetCount(predicate);
            var data = _ItemCommodityCostBRL.GetItemCommodityCosts(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemCommodityCosts(IEnumerable<tblICItemCommodityCost> costs, bool continueOnConflict = false)
        {
            foreach (var cost in costs)
                _ItemCommodityCostBRL.AddItemCommodityCost(cost);

            var result = _ItemCommodityCostBRL.Save(continueOnConflict);
            _ItemCommodityCostBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = costs,
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
        public HttpResponseMessage PutItemCommodityCosts(IEnumerable<tblICItemCommodityCost> costs, bool continueOnConflict = false)
        {
            foreach (var cost in costs)
                _ItemCommodityCostBRL.UpdateItemCommodityCost(cost);

            var result = _ItemCommodityCostBRL.Save(continueOnConflict);
            _ItemCommodityCostBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = costs,
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
        public HttpResponseMessage DeleteItemCommodityCosts(IEnumerable<tblICItemCommodityCost> costs, bool continueOnConflict = false)
        {
            foreach (var cost in costs)
                _ItemCommodityCostBRL.DeleteItemCommodityCost(cost);

            var result = _ItemCommodityCostBRL.Save(continueOnConflict);
            _ItemCommodityCostBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = costs,
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
