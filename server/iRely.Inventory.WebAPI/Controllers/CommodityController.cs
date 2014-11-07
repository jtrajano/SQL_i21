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
    public class CommodityController : ApiController
    {
        private Commodity _CommodityBRL = new Commodity();

        [HttpGet]
        public HttpResponseMessage SearchCommodities(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<CommodityVM>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<CommodityVM>(searchFilters);

            var data = _CommodityBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CommodityBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCommodities")]
        public HttpResponseMessage GetCommodities(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<CommodityVM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<CommodityVM>(searchFilters, true);

            var total = _CommodityBRL.GetCount(predicate);
            var data = _CommodityBRL.GetCommodities(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCompactCommodities")]
        public HttpResponseMessage GetCompactCommodities(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<CommodityVM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<CommodityVM>(searchFilters, true);

            var total = _CommodityBRL.GetCount(predicate);
            var data = _CommodityBRL.GetCompactCommodities(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCommodities(IEnumerable<tblICCommodity> commodities, bool continueOnConflict = false)
        {
            foreach (var commodity in commodities)
                _CommodityBRL.AddCommodity(commodity);

            var result = _CommodityBRL.Save(continueOnConflict);
            _CommodityBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = commodities,
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
        public HttpResponseMessage PutCommodities(IEnumerable<tblICCommodity> commodities, bool continueOnConflict = false)
        {
            foreach (var commodity in commodities)
                _CommodityBRL.UpdateCommodity(commodity);

            var result = _CommodityBRL.Save(continueOnConflict);
            _CommodityBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = commodities,
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
        public HttpResponseMessage DeleteCommodities(IEnumerable<tblICCommodity> commodities, bool continueOnConflict = false)
        {
            foreach (var commodity in commodities)
                _CommodityBRL.DeleteCommodity(commodity);

            var result = _CommodityBRL.Save(continueOnConflict);
            _CommodityBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = commodities,
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
