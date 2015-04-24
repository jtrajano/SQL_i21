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
    public class PostedLotController : ApiController
    {

        private PostedLot _PostedLotBRL = new PostedLot();

        [HttpGet]
        public HttpResponseMessage SearchPostedLots(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<vyuICGetPostedLot>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<vyuICGetPostedLot>(searchFilters);

            var data = _PostedLotBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _PostedLotBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetPostedLots")]
        public HttpResponseMessage GetPostedLots(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);

            // Workaround for null values on integer fields. 
            foreach (var deserializedFilter in searchFilters) 
            {
                deserializedFilter.v = string.IsNullOrEmpty(deserializedFilter.v) && deserializedFilter.c.StartsWith("int") ? "-1" : deserializedFilter.v;             
            }

            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<vyuICGetPostedLot>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intLotId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<vyuICGetPostedLot>(searchFilters, true);

            var total = _PostedLotBRL.GetCount(predicate);
            var data = _PostedLotBRL.GetPostedLots(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }
    }
}
