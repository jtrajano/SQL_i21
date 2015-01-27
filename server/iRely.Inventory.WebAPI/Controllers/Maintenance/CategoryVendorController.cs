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
    public class CategoryVendorController : ApiController
    {
         private CategoryVendor _CategoryVendorBRL = new CategoryVendor();

        [HttpGet]
        public HttpResponseMessage SearchCategoryVendors(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategoryVendor>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategoryVendor>(searchFilters);

            var data = _CategoryVendorBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CategoryVendorBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCategoryVendors")]
        public HttpResponseMessage GetCategoryVendors(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategoryVendor>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCategoryVendorId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategoryVendor>(searchFilters, true);

            var total = _CategoryVendorBRL.GetCount(predicate);
            var data = _CategoryVendorBRL.GetCategoryVendors(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCategoryVendors(IEnumerable<tblICCategoryVendor> vendors, bool continueOnConflict = false)
        {
            foreach (var vendor in vendors)
                _CategoryVendorBRL.AddCategoryVendor(vendor);

            var result = _CategoryVendorBRL.Save(continueOnConflict);
            _CategoryVendorBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = vendors,
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
        public HttpResponseMessage PutCategoryVendors(IEnumerable<tblICCategoryVendor> vendors, bool continueOnConflict = false)
        {
            foreach (var vendor in vendors)
                _CategoryVendorBRL.UpdateCategoryVendor(vendor);

            var result = _CategoryVendorBRL.Save(continueOnConflict);
            _CategoryVendorBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = vendors,
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
        public HttpResponseMessage DeleteCategoryVendors(IEnumerable<tblICCategoryVendor> vendors, bool continueOnConflict = false)
        {
            foreach (var vendor in vendors)
                _CategoryVendorBRL.DeleteCategoryVendor(vendor);

            var result = _CategoryVendorBRL.Save(continueOnConflict);
            _CategoryVendorBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = vendors,
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
