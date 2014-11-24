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
    public class ReadingPointController : ApiController
    {
         private ReadingPoint _ReadingPointBRL = new ReadingPoint();

        [HttpGet]
        public HttpResponseMessage SearchReadingPoints(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICReadingPoint>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICReadingPoint>(searchFilters);

            var data = _ReadingPointBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ReadingPointBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetReadingPoints")]
        public HttpResponseMessage GetReadingPoints(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICReadingPoint>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intReadingPointId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICReadingPoint>(searchFilters, true);

            var total = _ReadingPointBRL.GetCount(predicate);
            var data = _ReadingPointBRL.GetReadingPoints(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostReadingPoints(IEnumerable<tblICReadingPoint> points, bool continueOnConflict = false)
        {
            foreach (var point in points)
                _ReadingPointBRL.AddReadingPoint(point);

            var result = _ReadingPointBRL.Save(continueOnConflict);
            _ReadingPointBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = points,
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
        public HttpResponseMessage PutReadingPoints(IEnumerable<tblICReadingPoint> points, bool continueOnConflict = false)
        {
            foreach (var point in points)
                _ReadingPointBRL.UpdateReadingPoint(point);

            var result = _ReadingPointBRL.Save(continueOnConflict);
            _ReadingPointBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = points,
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
        public HttpResponseMessage DeleteReadingPoints(IEnumerable<tblICReadingPoint> points, bool continueOnConflict = false)
        {
            foreach (var point in points)
                _ReadingPointBRL.DeleteReadingPoint(point);

            var result = _ReadingPointBRL.Save(continueOnConflict);
            _ReadingPointBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = points,
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
