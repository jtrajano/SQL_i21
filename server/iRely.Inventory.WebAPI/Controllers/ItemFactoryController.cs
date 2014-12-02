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
    public class ItemFactoryController : ApiController
    {
        private ItemFactory _ItemFactoryBRL = new ItemFactory();

        [HttpGet]
        public HttpResponseMessage SearchItemFactories(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemFactory>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemFactory>(searchFilters);

            var data = _ItemFactoryBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemFactoryBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemFactories")]
        public HttpResponseMessage GetItemFactories(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemFactory>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemFactoryId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemFactory>(searchFilters, true);

            var total = _ItemFactoryBRL.GetCount(predicate);
            var data = _ItemFactoryBRL.GetItemFactories(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemOwners")]
        public HttpResponseMessage GetItemOwners(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemOwner>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemOwnerId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemOwner>(searchFilters, true);

            var total = _ItemFactoryBRL.GetOwnerCount(predicate);
            var data = _ItemFactoryBRL.GetItemOwners(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemFactories(IEnumerable<tblICItemFactory> factories, bool continueOnConflict = false)
        {
            foreach (var factory in factories)
                _ItemFactoryBRL.AddItemFactory(factory);

            var result = _ItemFactoryBRL.Save(continueOnConflict);
            _ItemFactoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = factories,
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
        public HttpResponseMessage PutItemFactories(IEnumerable<tblICItemFactory> factories, bool continueOnConflict = false)
        {
            foreach (var factory in factories)
                _ItemFactoryBRL.UpdateItemFactory(factory);

            var result = _ItemFactoryBRL.Save(continueOnConflict);
            _ItemFactoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = factories,
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
        public HttpResponseMessage DeleteItemFactories(IEnumerable<tblICItemFactory> factories, bool continueOnConflict = false)
        {
            foreach (var factory in factories)
                _ItemFactoryBRL.DeleteItemFactory(factory);

            var result = _ItemFactoryBRL.Save(continueOnConflict);
            _ItemFactoryBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = factories,
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
