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
    public class ItemUPCController : ApiController
    {
        private ItemUPC _ItemUPCBRL = new ItemUPC();

        [HttpGet]
        public HttpResponseMessage SearchItemUPCs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemUPC>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemUPC>(searchFilters);

            var data = _ItemUPCBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemUPCBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemUPCs")]
        public HttpResponseMessage GetItemUPCs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemUPC>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemUPCId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemUPC>(searchFilters, true);

            var total = _ItemUPCBRL.GetCount(predicate);
            var data = _ItemUPCBRL.GetItemUPCs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemUPCs(IEnumerable<tblICItemUPC> upcs, bool continueOnConflict = false)
        {
            foreach (var upc in upcs)
                _ItemUPCBRL.AddItemUPC(upc);

            var result = _ItemUPCBRL.Save(continueOnConflict);
            _ItemUPCBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = upcs,
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
        public HttpResponseMessage PutItemUPCs(IEnumerable<tblICItemUPC> upcs, bool continueOnConflict = false)
        {
            foreach (var upc in upcs)
                _ItemUPCBRL.UpdateItemUPC(upc);

            var result = _ItemUPCBRL.Save(continueOnConflict);
            _ItemUPCBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = upcs,
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
        public HttpResponseMessage DeleteItemUPCs(IEnumerable<tblICItemUPC> upcs, bool continueOnConflict = false)
        {
            foreach (var upc in upcs)
                _ItemUPCBRL.DeleteItemUPC(upc);

            var result = _ItemUPCBRL.Save(continueOnConflict);
            _ItemUPCBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = upcs,
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
