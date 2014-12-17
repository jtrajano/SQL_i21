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
    public class ItemAccountController : ApiController
    {
        private ItemAccount _ItemAccountBRL = new ItemAccount();

        [HttpGet]
        public HttpResponseMessage SearchItemAccounts(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemAccount>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemAccount>(searchFilters);

            var data = _ItemAccountBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemAccountBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemAccounts")]
        public HttpResponseMessage GetItemAccounts(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemAccount>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemAccountId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemAccount>(searchFilters, true);

            var total = _ItemAccountBRL.GetCount(predicate);
            var data = _ItemAccountBRL.GetItemAccounts(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemAccounts(IEnumerable<tblICItemAccount> accounts, bool continueOnConflict = false)
        {
            foreach (var account in accounts)
                _ItemAccountBRL.AddItemAccount(account);

            var result = _ItemAccountBRL.Save(continueOnConflict);
            _ItemAccountBRL.Dispose();

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
        public HttpResponseMessage PutItemAccounts(IEnumerable<tblICItemAccount> accounts, bool continueOnConflict = false)
        {
            foreach (var account in accounts)
                _ItemAccountBRL.UpdateItemAccount(account);

            var result = _ItemAccountBRL.Save(continueOnConflict);
            _ItemAccountBRL.Dispose();

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
        public HttpResponseMessage DeleteItemAccounts(IEnumerable<tblICItemAccount> accounts, bool continueOnConflict = false)
        {
            foreach (var account in accounts)
                _ItemAccountBRL.DeleteItemAccount(account);

            var result = _ItemAccountBRL.Save(continueOnConflict);
            _ItemAccountBRL.Dispose();

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
