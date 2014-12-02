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
    public class ItemPOSController : ApiController
    {
        private ItemPOS _ItemPOSBRL = new ItemPOS();

        [HttpGet]
        public HttpResponseMessage SearchItemPOSCategories(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemPOSCategory>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemPOSCategory>(searchFilters);

            var data = _ItemPOSBRL.GetPOSCategorySearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemPOSBRL.GetPOSCategoryCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemPOSCategories")]
        public HttpResponseMessage GetItemPOSCategories(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemPOSCategory>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemPOSCategoryId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemPOSCategory>(searchFilters, true);

            var total = _ItemPOSBRL.GetPOSCategoryCount(predicate);
            var data = _ItemPOSBRL.GetItemPOSCategories(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        public HttpResponseMessage SearchItemPOSSLAs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemPOSSLA>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemPOSSLA>(searchFilters);

            var data = _ItemPOSBRL.GetPOSSLASearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemPOSBRL.GetPOSSLACount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemPOSSLAs")]
        public HttpResponseMessage GetItemPOSSLAs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemPOSSLA>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemPOSSLAId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemPOSSLA>(searchFilters, true);

            var total = _ItemPOSBRL.GetPOSSLACount(predicate);
            var data = _ItemPOSBRL.GetItemPOSSLAs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }
    }
}
