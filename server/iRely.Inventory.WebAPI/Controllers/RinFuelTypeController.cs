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
    public class FuelCategoryController : ApiController
    {
        private FuelCategory _FuelCategoryBRL = new FuelCategory();

        [HttpGet]
        public HttpResponseMessage SearchFuelCategories(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFuelCategory>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFuelCategory>(searchFilters);

            var data = _FuelCategoryBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _FuelCategoryBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetFuelCategories")]
        public HttpResponseMessage GetFuelCategories(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFuelCategory>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRinFuelCategoryId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFuelCategory>(searchFilters, true);

            var total = _FuelCategoryBRL.GetCount(predicate);
            var data = _FuelCategoryBRL.GetFuelCategories(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostFuelCategories(IEnumerable<tblICRinFuelCategory> categories, bool continueOnConflict = false)
        {
            foreach (var category in categories)
                _FuelCategoryBRL.AddFuelCategory(category);

            var result = _FuelCategoryBRL.Save(continueOnConflict);
            _FuelCategoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = categories,
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
        public HttpResponseMessage PutFuelCategories(IEnumerable<tblICRinFuelCategory> categories, bool continueOnConflict = false)
        {
            foreach (var category in categories)
                _FuelCategoryBRL.UpdateFuelCategory(category);

            var result = _FuelCategoryBRL.Save(continueOnConflict);
            _FuelCategoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = categories,
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
        public HttpResponseMessage DeleteFuelCategories(IEnumerable<tblICRinFuelCategory> categories, bool continueOnConflict = false)
        {
            foreach (var category in categories)
                _FuelCategoryBRL.DeleteFuelCategory(category);

            var result = _FuelCategoryBRL.Save(continueOnConflict);
            _FuelCategoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = categories,
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
