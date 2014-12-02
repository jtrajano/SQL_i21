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
    public class ItemXrefController : ApiController
    {
        private ItemXref _ItemXrefBRL = new ItemXref();

        [HttpGet]
        public HttpResponseMessage SearchItemVendorXrefs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemVendorXref>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemVendorXref>(searchFilters);

            var data = _ItemXrefBRL.GetVendorXrefSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemXrefBRL.GetVendorXrefCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemVendorXrefs")]
        public HttpResponseMessage GetItemVendorXrefs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemVendorXref>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemVendorXrefId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemVendorXref>(searchFilters, true);

            var total = _ItemXrefBRL.GetVendorXrefCount(predicate);
            var data = _ItemXrefBRL.GetItemVendorXrefs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        public HttpResponseMessage SearchItemCustomerXrefs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemCustomerXref>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemCustomerXref>(searchFilters);

            var data = _ItemXrefBRL.GetCustomerXrefSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemXrefBRL.GetCustomerXrefCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemCustomerXrefs")]
        public HttpResponseMessage GetItemCustomerXrefs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemCustomerXref>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemCustomerXrefId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemCustomerXref>(searchFilters, true);

            var total = _ItemXrefBRL.GetCustomerXrefCount(predicate);
            var data = _ItemXrefBRL.GetItemCustomerXrefs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }
    }
}
