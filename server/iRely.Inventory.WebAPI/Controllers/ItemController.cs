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
    public class ItemController : ApiController
    {
        private Item _ItemBRL = new Item();

        public HttpResponseMessage SearchItems(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItem>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItem>(searchFilters);

            var data = _ItemBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItems")]
        public HttpResponseMessage GetItems(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItem>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItem>(searchFilters, true);

            var total = _ItemBRL.GetCount(predicate);
            var data = _ItemBRL.GetItems(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItems(IEnumerable<tblICItem> items, bool continueOnConflict = false)
        {
            foreach (var item in items)
                _ItemBRL.AddItem(item);

            var result = _ItemBRL.Save(continueOnConflict);
            _ItemBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = items,
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
        public HttpResponseMessage PutItems(IEnumerable<tblICItem> items, bool continueOnConflict = false)
        {
            foreach (var item in items)
                _ItemBRL.UpdateItem(item);

            var result = _ItemBRL.Save(continueOnConflict);
            _ItemBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = items,
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
        public HttpResponseMessage DeleteItems(IEnumerable<tblICItem> items, bool continueOnConflict = false)
        {
            foreach (var item in items)
                _ItemBRL.DeleteItem(item);

            var result = _ItemBRL.Save(continueOnConflict);
            _ItemBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = items,
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
