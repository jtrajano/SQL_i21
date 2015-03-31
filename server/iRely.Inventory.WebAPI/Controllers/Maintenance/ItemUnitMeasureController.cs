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
    public class ItemUnitMeasureController : ApiController
    {

        private ItemUnitMeasure _ItemUnitMeasureBRL = new ItemUnitMeasure();

        [HttpGet]
        public HttpResponseMessage SearchItemUnitMeasures(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemUOM>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemUOM>(searchFilters);

            var data = _ItemUnitMeasureBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemUnitMeasureBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemUnitMeasures")]
        public HttpResponseMessage GetItemUnitMeasures(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemUOM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemUOMId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemUOM>(searchFilters, true);

            var total = _ItemUnitMeasureBRL.GetCount(predicate);
            var data = _ItemUnitMeasureBRL.GetItemUnitMeasures(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetWeightUOMs")]
        public HttpResponseMessage GetWeightUOMs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemUOM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemUOMId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemUOM>(searchFilters, true);
            
            var total = _ItemUnitMeasureBRL.GetCount(predicate);
            var data = _ItemUnitMeasureBRL.GetItemUnitMeasures(page, start, page == 0 ? total : limit, sortSelector, predicate);

            var finalData = data.ToList().Where(p=> p.strUnitType == "Weight").ToList();

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = finalData,
                total = finalData.Count
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemUnitMeasures(IEnumerable<tblICItemUOM> uoms, bool continueOnConflict = false)
        {
            foreach (var uom in uoms)
                _ItemUnitMeasureBRL.AddItemUnitMeasure(uom);

            var result = _ItemUnitMeasureBRL.Save(continueOnConflict);
            _ItemUnitMeasureBRL.Dispose();

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
        public HttpResponseMessage PutItemUnitMeasures(IEnumerable<tblICItemUOM> uoms, bool continueOnConflict = false)
        {
            foreach (var uom in uoms)
                _ItemUnitMeasureBRL.UpdateItemUnitMeasure(uom);

            var result = _ItemUnitMeasureBRL.Save(continueOnConflict);
            _ItemUnitMeasureBRL.Dispose();

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
        public HttpResponseMessage DeleteItemUnitMeasures(IEnumerable<tblICItemUOM> uoms, bool continueOnConflict = false)
        {
            foreach (var uom in uoms)
                _ItemUnitMeasureBRL.DeleteItemUnitMeasure(uom);

            var result = _ItemUnitMeasureBRL.Save(continueOnConflict);
            _ItemUnitMeasureBRL.Dispose();

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
