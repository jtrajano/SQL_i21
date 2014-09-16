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
    public class PatronageCategoryController : ApiController
    {
        private PatronageCategory _PatronageCategoryBRL = new PatronageCategory();

        public HttpResponseMessage SearchPatronageCategories(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICPatronageCategory>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICPatronageCategory>(searchFilters);

            var data = _PatronageCategoryBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _PatronageCategoryBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetPatronageCategories")]
        public HttpResponseMessage GetPatronageCategories(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICPatronageCategory>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intPatronageCategoryId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICPatronageCategory>(searchFilters, true);

            var total = _PatronageCategoryBRL.GetCount(predicate);
            var data = _PatronageCategoryBRL.GetPatronageCategories(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostPatronageCategories(IEnumerable<tblICPatronageCategory> PatronageCategories, bool continueOnConflict = false)
        {
            foreach (var PatronageCategory in PatronageCategories)
                _PatronageCategoryBRL.AddPatronageCategory(PatronageCategory);

            var result = _PatronageCategoryBRL.Save(continueOnConflict);
            _PatronageCategoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = PatronageCategories,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [AcceptVerbs("POST", "PUT")]
        [HttpPost]
        [HttpPut]
        public HttpResponseMessage PutPatronageCategories(IEnumerable<tblICPatronageCategory> PatronageCategories, bool continueOnConflict = false)
        {
            foreach (var PatronageCategory in PatronageCategories)
                _PatronageCategoryBRL.UpdatePatronageCategory(PatronageCategory);

            var result = _PatronageCategoryBRL.Save(continueOnConflict);
            _PatronageCategoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = PatronageCategories,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [AcceptVerbs("POST", "DELETE")]
        [HttpPost]
        [HttpDelete]
        public HttpResponseMessage DeletePatronageCategories(IEnumerable<tblICPatronageCategory> PatronageCategories, bool continueOnConflict = false)
        {
            foreach (var PatronageCategory in PatronageCategories)
                _PatronageCategoryBRL.DeletePatronageCategory(PatronageCategory);

            var result = _PatronageCategoryBRL.Save(continueOnConflict);
            _PatronageCategoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = PatronageCategories,
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
