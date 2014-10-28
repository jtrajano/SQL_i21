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
    public class CommodityAttributeController : ApiController
    {

        private CommodityAttribute _CommodityAttributeBRL = new CommodityAttribute();

        [HttpGet]
        public HttpResponseMessage SearchCommodityAttributes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityAttribute>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityAttribute>(searchFilters);

            var data = _CommodityAttributeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CommodityAttributeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCommodityAttributes")]
        public HttpResponseMessage GetCommodityAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityAttribute>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityAttribute>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetCount(predicate);
            var data = _CommodityAttributeBRL.GetCommodityAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCommodityAttributes(IEnumerable<tblICCommodityAttribute> attributes, bool continueOnConflict = false)
        {
            foreach (var attribute in attributes)
                _CommodityAttributeBRL.AddCommodityAttribute(attribute);

            var result = _CommodityAttributeBRL.Save(continueOnConflict);
            _CommodityAttributeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = attributes,
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
        public HttpResponseMessage PutCommodityAttributes(IEnumerable<tblICCommodityAttribute> attributes, bool continueOnConflict = false)
        {
            foreach (var attribute in attributes)
                _CommodityAttributeBRL.UpdateCommodityAttribute(attribute);

            var result = _CommodityAttributeBRL.Save(continueOnConflict);
            _CommodityAttributeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = attributes,
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
        public HttpResponseMessage DeleteCommodityAttributes(IEnumerable<tblICCommodityAttribute> attributes, bool continueOnConflict = false)
        {
            foreach (var attribute in attributes)
                _CommodityAttributeBRL.DeleteCommodityAttribute(attribute);

            var result = _CommodityAttributeBRL.Save(continueOnConflict);
            _CommodityAttributeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = attributes,
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
