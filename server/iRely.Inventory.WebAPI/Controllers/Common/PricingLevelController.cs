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
    public class PricingLevelController : ApiController
    {
        private PricingLevel _PricingLevelBRL = new PricingLevel();

        [HttpGet]
        public HttpResponseMessage SearchPricingLevels(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<vyuSMGetLocationPricingLevel>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<vyuSMGetLocationPricingLevel>(searchFilters);

            var data = _PricingLevelBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _PricingLevelBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetPricingLevels")]
        public HttpResponseMessage GetPricingLevels(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<vyuSMGetLocationPricingLevel>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intKey", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<vyuSMGetLocationPricingLevel>(searchFilters, true);

            var total = _PricingLevelBRL.GetCount(predicate);
            var data = _PricingLevelBRL.GetPricingLevels(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostPricingLevels(IEnumerable<vyuSMGetLocationPricingLevel> pricingLevels, bool continueOnConflict = false)
        {
            foreach (var pricingLevel in pricingLevels)
                _PricingLevelBRL.AddPricingLevel(pricingLevel);

            var result = _PricingLevelBRL.Save(continueOnConflict);
            _PricingLevelBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = pricingLevels,
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
        public HttpResponseMessage PutPricingLevels(IEnumerable<vyuSMGetLocationPricingLevel> pricingLevels, bool continueOnConflict = false)
        {
            foreach (var pricingLevel in pricingLevels)
                _PricingLevelBRL.UpdatePricingLevel(pricingLevel);

            var result = _PricingLevelBRL.Save(continueOnConflict);
            _PricingLevelBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = pricingLevels,
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
        public HttpResponseMessage DeletePricingLevels(IEnumerable<vyuSMGetLocationPricingLevel> pricingLevels, bool continueOnConflict = false)
        {
            foreach (var pricingLevel in pricingLevels)
                _PricingLevelBRL.DeletePricingLevel(pricingLevel);

            var result = _PricingLevelBRL.Save(continueOnConflict);
            _PricingLevelBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = pricingLevels,
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
