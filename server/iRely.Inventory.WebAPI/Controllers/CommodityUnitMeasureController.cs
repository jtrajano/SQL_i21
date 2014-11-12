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
    public class CommodityUnitMeasureController : ApiController
    {

        private CommodityUnitMeasure _CommodityUnitMeasureBRL = new CommodityUnitMeasure();

        [HttpGet]
        public HttpResponseMessage SearchCommodityUnitMeasures(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityUnitMeasure>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityUnitMeasure>(searchFilters);

            var data = _CommodityUnitMeasureBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CommodityUnitMeasureBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCommodityUnitMeasures")]
        public HttpResponseMessage GetCommodityUnitMeasures(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCommodityUnitMeasure>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCommodityUnitMeasureId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCommodityUnitMeasure>(searchFilters, true);

            var total = _CommodityUnitMeasureBRL.GetCount(predicate);
            var data = _CommodityUnitMeasureBRL.GetCommodityUnitMeasures(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCommodityUnitMeasures(IEnumerable<tblICCommodityUnitMeasure> uoms, bool continueOnConflict = false)
        {
            foreach (var uom in uoms)
                _CommodityUnitMeasureBRL.AddCommodityUnitMeasure(uom);

            var result = _CommodityUnitMeasureBRL.Save(continueOnConflict);
            _CommodityUnitMeasureBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = uoms,
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
        public HttpResponseMessage PutCommodityUnitMeasures(IEnumerable<tblICCommodityUnitMeasure> uoms, bool continueOnConflict = false)
        {
            foreach (var uom in uoms)
                _CommodityUnitMeasureBRL.UpdateCommodityUnitMeasure(uom);

            var result = _CommodityUnitMeasureBRL.Save(continueOnConflict);
            _CommodityUnitMeasureBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = uoms,
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
        public HttpResponseMessage DeleteCommodityUnitMeasures(IEnumerable<tblICCommodityUnitMeasure> uoms, bool continueOnConflict = false)
        {
            foreach (var uom in uoms)
                _CommodityUnitMeasureBRL.DeleteCommodityUnitMeasure(uom);

            var result = _CommodityUnitMeasureBRL.Save(continueOnConflict);
            _CommodityUnitMeasureBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = uoms,
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
