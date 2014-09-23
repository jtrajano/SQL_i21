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
    public class UnitMeasureController : ApiController
    {
        private UnitMeasure _UnitMeasureBRL = new UnitMeasure();

        public HttpResponseMessage SearchUnitMeasures(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICUnitMeasure>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICUnitMeasure>(searchFilters);

            var data = _UnitMeasureBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _UnitMeasureBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetUnitMeasures")]
        public HttpResponseMessage GetUnitMeasures(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICUnitMeasure>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intUnitMeasureId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICUnitMeasure>(searchFilters, true);

            var total = _UnitMeasureBRL.GetCount(predicate);
            var data = _UnitMeasureBRL.GetUnitMeasures(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostUnitMeasures(IEnumerable<tblICUnitMeasure> UnitMeasures, bool continueOnConflict = false)
        {
            foreach (var UnitMeasure in UnitMeasures)
                _UnitMeasureBRL.AddUnitMeasure(UnitMeasure);

            var result = _UnitMeasureBRL.Save(continueOnConflict);
            _UnitMeasureBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = UnitMeasures,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [AcceptVerbs("POST", "PUT")]
        [HttpPut]
        public HttpResponseMessage PutUnitMeasures(IEnumerable<tblICUnitMeasure> UnitMeasures, bool continueOnConflict = false)
        {
            foreach (var UnitMeasure in UnitMeasures)
                _UnitMeasureBRL.UpdateUnitMeasure(UnitMeasure);

            var result = _UnitMeasureBRL.Save(continueOnConflict);
            _UnitMeasureBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = UnitMeasures,
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
        public HttpResponseMessage DeleteUnitMeasures(IEnumerable<tblICUnitMeasure> UnitMeasures, bool continueOnConflict = false)
        {
            foreach (var UnitMeasure in UnitMeasures)
                _UnitMeasureBRL.DeleteUnitMeasure(UnitMeasure);

            var result = _UnitMeasureBRL.Save(continueOnConflict);
            _UnitMeasureBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = UnitMeasures,
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
