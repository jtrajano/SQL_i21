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
    public class CategoryAccountController : ApiController
    {
         private CategoryAccount _CategoryAccountBRL = new CategoryAccount();

        [HttpGet]
        public HttpResponseMessage SearchCategoryAccounts(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategoryAccount>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategoryAccount>(searchFilters);

            var data = _CategoryAccountBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CategoryAccountBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCategoryAccounts")]
        public HttpResponseMessage GetCategoryAccounts(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCategoryAccount>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCategoryAccountId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCategoryAccount>(searchFilters, true);

            var total = _CategoryAccountBRL.GetCount(predicate);
            var data = _CategoryAccountBRL.GetCategoryAccounts(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCategoryAccounts(IEnumerable<tblICCategoryAccount> accounts, bool continueOnConflict = false)
        {
            foreach (var account in accounts)
                _CategoryAccountBRL.AddCategoryAccount(account);

            var result = _CategoryAccountBRL.Save(continueOnConflict);
            _CategoryAccountBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = accounts,
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
        public HttpResponseMessage PutCategoryAccounts(IEnumerable<tblICCategoryAccount> accounts, bool continueOnConflict = false)
        {
            foreach (var account in accounts)
                _CategoryAccountBRL.UpdateCategoryAccount(account);

            var result = _CategoryAccountBRL.Save(continueOnConflict);
            _CategoryAccountBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = accounts,
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
        public HttpResponseMessage DeleteCategoryAccounts(IEnumerable<tblICCategoryAccount> accounts, bool continueOnConflict = false)
        {
            foreach (var account in accounts)
                _CategoryAccountBRL.DeleteCategoryAccount(account);

            var result = _CategoryAccountBRL.Save(continueOnConflict);
            _CategoryAccountBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = accounts,
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
