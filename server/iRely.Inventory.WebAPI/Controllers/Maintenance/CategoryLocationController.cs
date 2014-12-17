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
    public class CategoryLocationController : ApiController
    {

        private CategoryLocation _CategoryLocationBRL = new CategoryLocation();

        [HttpGet]
        public HttpResponseMessage SearchCategoryLocations(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategoryLocation>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategoryLocation>(searchFilters);

            var data = _CategoryLocationBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CategoryLocationBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCategoryLocations")]
        public HttpResponseMessage GetCategoryLocations(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategoryLocation>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCategoryLocationId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategoryLocation>(searchFilters, true);

            var total = _CategoryLocationBRL.GetCount(predicate);
            var data = _CategoryLocationBRL.GetCategoryLocations(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCategoryLocations(IEnumerable<tblICCategoryLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _CategoryLocationBRL.AddCategoryLocation(location);

            var result = _CategoryLocationBRL.Save(continueOnConflict);
            _CategoryLocationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
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
        public HttpResponseMessage PutCategoryLocations(IEnumerable<tblICCategoryLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _CategoryLocationBRL.UpdateCategoryLocation(location);

            var result = _CategoryLocationBRL.Save(continueOnConflict);
            _CategoryLocationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
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
        public HttpResponseMessage DeleteCategoryLocations(IEnumerable<tblICCategoryLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _CategoryLocationBRL.DeleteCategoryLocation(location);

            var result = _CategoryLocationBRL.Save(continueOnConflict);
            _CategoryLocationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
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
