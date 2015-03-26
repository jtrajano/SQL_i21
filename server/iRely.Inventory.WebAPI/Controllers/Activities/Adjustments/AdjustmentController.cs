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
    public class AdjustmentController : ApiController
    {
         private Adjustment _AdjustmentBRL = new Adjustment();

        [HttpGet]
        public HttpResponseMessage SearchAdjustments(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<AdjustmentVM>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<AdjustmentVM>(searchFilters);

            var data = _AdjustmentBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _AdjustmentBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetAdjustments")]
        public HttpResponseMessage GetAdjustments(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<AdjustmentVM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intInventoryAdjustmentId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<AdjustmentVM>(searchFilters, true);

            var total = _AdjustmentBRL.GetCount(predicate);
            var data = _AdjustmentBRL.GetAdjustments(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostAdjustments(IEnumerable<tblICInventoryAdjustment> adjustments, bool continueOnConflict = false)
        {
            foreach (var adjustment in adjustments)
                _AdjustmentBRL.AddAdjustment(adjustment);

            var result = _AdjustmentBRL.Save(continueOnConflict);
            _AdjustmentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = adjustments,
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
        public HttpResponseMessage PutAdjustments(IEnumerable<tblICInventoryAdjustment> adjustments, bool continueOnConflict = false)
        {
            foreach (var adjustment in adjustments)
                _AdjustmentBRL.UpdateAdjustment(adjustment);

            var result = _AdjustmentBRL.Save(continueOnConflict);
            _AdjustmentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = adjustments,
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
        public HttpResponseMessage DeleteAdjustments(IEnumerable<tblICInventoryAdjustment> adjustments, bool continueOnConflict = false)
        {
            foreach (var adjustment in adjustments)
                _AdjustmentBRL.DeleteAdjustment(adjustment);

            var result = _AdjustmentBRL.Save(continueOnConflict);
            _AdjustmentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = adjustments,
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
