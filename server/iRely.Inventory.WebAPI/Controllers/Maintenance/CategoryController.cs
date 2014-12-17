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
    public class CategoryController : ApiController
    {
        private Category _CategoryBRL = new Category();

        [HttpGet]
        public HttpResponseMessage SearchCategories(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategory>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategory>(searchFilters);

            var data = _CategoryBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CategoryBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCategories")]
        public HttpResponseMessage GetCategories(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategory>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCategoryId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategory>(searchFilters, true);

            var total = _CategoryBRL.GetCount(predicate);
            var data = _CategoryBRL.GetCategories(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCategories(IEnumerable<tblICCategory> categories, bool continueOnConflict = false)
        {
            foreach (var category in categories)
                _CategoryBRL.AddCategory(category);

            var result = _CategoryBRL.Save(continueOnConflict);
            _CategoryBRL.Dispose();
            
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
        public HttpResponseMessage PutCategories(IEnumerable<tblICCategory> categories, bool continueOnConflict = false)
        {
            foreach (var category in categories)
                _CategoryBRL.UpdateCategory(category);

            var result = _CategoryBRL.Save(continueOnConflict);
            _CategoryBRL.Dispose();

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
        public HttpResponseMessage DeleteCategories(IEnumerable<tblICCategory> categories, bool continueOnConflict = false)
        {
            foreach (var category in categories)
                _CategoryBRL.DeleteCategory(category);

            var result = _CategoryBRL.Save(continueOnConflict);
            _CategoryBRL.Dispose();

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
