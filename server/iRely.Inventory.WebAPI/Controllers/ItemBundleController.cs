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
    public class ItemBundleController : ApiController
    {
        private ItemBundle _ItemBundleBRL = new ItemBundle();

        [HttpGet]
        public HttpResponseMessage SearchItemBundles(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemBundle>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemBundle>(searchFilters);

            var data = _ItemBundleBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemBundleBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemBundles")]
        public HttpResponseMessage GetItemBundles(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemBundle>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemBundleId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemBundle>(searchFilters, true);

            var total = _ItemBundleBRL.GetCount(predicate);
            var data = _ItemBundleBRL.GetItemBundles(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemBundles(IEnumerable<tblICItemBundle> bundles, bool continueOnConflict = false)
        {
            foreach (var bundle in bundles)
                _ItemBundleBRL.AddItemBundle(bundle);

            var result = _ItemBundleBRL.Save(continueOnConflict);
            _ItemBundleBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = bundles,
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
        public HttpResponseMessage PutItemBundles(IEnumerable<tblICItemBundle> bundles, bool continueOnConflict = false)
        {
            foreach (var bundle in bundles)
                _ItemBundleBRL.UpdateItemBundle(bundle);

            var result = _ItemBundleBRL.Save(continueOnConflict);
            _ItemBundleBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = bundles,
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
        public HttpResponseMessage DeleteItemBundles(IEnumerable<tblICItemBundle> bundles, bool continueOnConflict = false)
        {
            foreach (var bundle in bundles)
                _ItemBundleBRL.DeleteItemBundle(bundle);

            var result = _ItemBundleBRL.Save(continueOnConflict);
            _ItemBundleBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = bundles,
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
