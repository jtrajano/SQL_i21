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
    public class MeasurementController : ApiController
    {
         private Measurement _MeasurementBRL = new Measurement();

        [HttpGet]
        public HttpResponseMessage SearchMeasurements(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICMeasurement>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICMeasurement>(searchFilters);

            var data = _MeasurementBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _MeasurementBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetMeasurements")]
        public HttpResponseMessage GetMeasurements(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICMeasurement>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intMeasurementId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICMeasurement>(searchFilters, true);

            var total = _MeasurementBRL.GetCount(predicate);
            var data = _MeasurementBRL.GetMeasurements(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostMeasurements(IEnumerable<tblICMeasurement> measurements, bool continueOnConflict = false)
        {
            foreach (var measurement in measurements)
                _MeasurementBRL.AddMeasurement(measurement);

            var result = _MeasurementBRL.Save(continueOnConflict);
            _MeasurementBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = measurements,
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
        public HttpResponseMessage PutMeasurements(IEnumerable<tblICMeasurement> measurements, bool continueOnConflict = false)
        {
            foreach (var measurement in measurements)
                _MeasurementBRL.UpdateMeasurement(measurement);

            var result = _MeasurementBRL.Save(continueOnConflict);
            _MeasurementBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = measurements,
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
        public HttpResponseMessage DeleteMeasurements(IEnumerable<tblICMeasurement> measurements, bool continueOnConflict = false)
        {
            foreach (var measurement in measurements)
                _MeasurementBRL.DeleteMeasurement(measurement);

            var result = _MeasurementBRL.Save(continueOnConflict);
            _MeasurementBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = measurements,
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
