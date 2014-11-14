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

        [HttpGet]
        [ActionName("GetClassAttributes")]
        public HttpResponseMessage GetClassAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityClassVariant>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityClassVariant>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetClassCount(predicate);
            var data = _CommodityAttributeBRL.GetClassAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetGradeAttributes")]
        public HttpResponseMessage GetGradeAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityGrade>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityGrade>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetGradeCount(predicate);
            var data = _CommodityAttributeBRL.GetGradeAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetOriginAttributes")]
        public HttpResponseMessage GetOriginAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityOrigin>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityOrigin>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetOriginCount(predicate);
            var data = _CommodityAttributeBRL.GetOriginAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetProductLineAttributes")]
        public HttpResponseMessage GetProductLineAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityProductLine>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityProductLine>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetProductLineCount(predicate);
            var data = _CommodityAttributeBRL.GetProductLineAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetProductTypeAttributes")]
        public HttpResponseMessage GetProductTypeAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityProductType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityProductType>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetProductTypeCount(predicate);
            var data = _CommodityAttributeBRL.GetProductTypeAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRegionAttributes")]
        public HttpResponseMessage GetRegionAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityRegion>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityRegion>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetRegionCount(predicate);
            var data = _CommodityAttributeBRL.GetRegionAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetSeasonAttributes")]
        public HttpResponseMessage GetSeasonAttributes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommoditySeason>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityAttributeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommoditySeason>(searchFilters, true);

            var total = _CommodityAttributeBRL.GetSeasonCount(predicate);
            var data = _CommodityAttributeBRL.GetSeasonAttributes(page, start, page == 0 ? total : limit, sortSelector, predicate);

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
