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
    public class ItemKitController : ApiController
    {
        private ItemKit _ItemKitBRL = new ItemKit();

        [HttpGet]
        public HttpResponseMessage SearchItemKits(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemKit>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemKit>(searchFilters);

            var data = _ItemKitBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemKitBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemKits")]
        public HttpResponseMessage GetItemKits(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemKit>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemKitId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemKit>(searchFilters, true);

            var total = _ItemKitBRL.GetCount(predicate);
            var data = _ItemKitBRL.GetItemKits(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemKits(IEnumerable<tblICItemKit> kits, bool continueOnConflict = false)
        {
            foreach (var kit in kits)
                _ItemKitBRL.AddItemKit(kit);

            var result = _ItemKitBRL.Save(continueOnConflict);
            _ItemKitBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = kits,
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
        public HttpResponseMessage PutItemKits(IEnumerable<tblICItemKit> kits, bool continueOnConflict = false)
        {
            foreach (var kit in kits)
                _ItemKitBRL.UpdateItemKit(kit);

            var result = _ItemKitBRL.Save(continueOnConflict);
            _ItemKitBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = kits,
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
        public HttpResponseMessage DeleteItemKits(IEnumerable<tblICItemKit> kits, bool continueOnConflict = false)
        {
            foreach (var kit in kits)
                _ItemKitBRL.DeleteItemKit(kit);

            var result = _ItemKitBRL.Save(continueOnConflict);
            _ItemKitBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = kits,
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
