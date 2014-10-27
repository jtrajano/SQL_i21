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
    public class ItemPricingController : ApiController
    {
        private ItemPricing _ItemPricingBRL = new ItemPricing();

        [HttpGet]
        public HttpResponseMessage SearchItemPricings(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemPricing>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemPricing>(searchFilters);

            var data = _ItemPricingBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemPricingBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemPricings")]
        public HttpResponseMessage GetItemPricings(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemPricing>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemPricingId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemPricing>(searchFilters, true);

            var total = _ItemPricingBRL.GetCount(predicate);
            var data = _ItemPricingBRL.GetItemPricings(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemPricings(IEnumerable<tblICItemPricing> pricings, bool continueOnConflict = false)
        {
            foreach (var pricing in pricings)
                _ItemPricingBRL.AddItemPricing(pricing);

            var result = _ItemPricingBRL.Save(continueOnConflict);
            _ItemPricingBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = pricings,
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
        public HttpResponseMessage PutItemPricings(IEnumerable<tblICItemPricing> pricings, bool continueOnConflict = false)
        {
            foreach (var pricing in pricings)
                _ItemPricingBRL.UpdateItemPricing(pricing);

            var result = _ItemPricingBRL.Save(continueOnConflict);
            _ItemPricingBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = pricings,
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
        public HttpResponseMessage DeleteItemPricings(IEnumerable<tblICItemPricing> pricings, bool continueOnConflict = false)
        {
            foreach (var pricing in pricings)
                _ItemPricingBRL.DeleteItemPricing(pricing);

            var result = _ItemPricingBRL.Save(continueOnConflict);
            _ItemPricingBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = pricings,
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
