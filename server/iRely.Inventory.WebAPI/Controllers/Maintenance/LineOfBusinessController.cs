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
    public class LineOfBusinessController : ApiController
    {

        private LineOfBusiness _LineOfBusinessBRL = new LineOfBusiness();

        [HttpGet]
        public HttpResponseMessage SearchLineOfBusinesses(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICLineOfBusiness>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICLineOfBusiness>(searchFilters);

            var data = _LineOfBusinessBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _LineOfBusinessBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetLineOfBusinesses")]
        public HttpResponseMessage GetLineOfBusinesses(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICLineOfBusiness>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intLineOfBusinessId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICLineOfBusiness>(searchFilters, true);

            var total = _LineOfBusinessBRL.GetCount(predicate);
            var data = _LineOfBusinessBRL.GetLineOfBusinesses(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostLineOfBusinesses(IEnumerable<tblICLineOfBusiness> lines, bool continueOnConflict = false)
        {
            foreach (var line in lines)
                _LineOfBusinessBRL.AddLineOfBusiness(line);

            var result = _LineOfBusinessBRL.Save(continueOnConflict);
            _LineOfBusinessBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lines,
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
        public HttpResponseMessage PutLineOfBusinesses(IEnumerable<tblICLineOfBusiness> lines, bool continueOnConflict = false)
        {
            foreach (var line in lines)
                _LineOfBusinessBRL.UpdateLineOfBusiness(line);

            var result = _LineOfBusinessBRL.Save(continueOnConflict);
            _LineOfBusinessBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lines,
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
        public HttpResponseMessage DeleteLineOfBusinesses(IEnumerable<tblICLineOfBusiness> lines, bool continueOnConflict = false)
        {
            foreach (var line in lines)
                _LineOfBusinessBRL.DeleteLineOfBusiness(line);

            var result = _LineOfBusinessBRL.Save(continueOnConflict);
            _LineOfBusinessBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lines,
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
