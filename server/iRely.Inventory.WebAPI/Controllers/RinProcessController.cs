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
    public class RinProcessController : ApiController
    {
        private RinProcess _RinProcessBRL = new RinProcess();

        [HttpGet]
        public HttpResponseMessage SearchRinProcesses(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinProcess>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinProcess>(searchFilters);

            var data = _RinProcessBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _RinProcessBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRinProcesses")]
        public HttpResponseMessage GetRinProcesses(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinProcess>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRinProcessId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinProcess>(searchFilters, true);

            var total = _RinProcessBRL.GetCount(predicate);
            var data = _RinProcessBRL.GetRinProcesses(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostRinProcesses(IEnumerable<tblICRinProcess> RinProcesses, bool continueOnConflict = false)
        {
            foreach (var RinProcess in RinProcesses)
                _RinProcessBRL.AddRinProcess(RinProcess);

            var result = _RinProcessBRL.Save(continueOnConflict);
            _RinProcessBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinProcesses,
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
        public HttpResponseMessage PutRinProcesses(IEnumerable<tblICRinProcess> RinProcesses, bool continueOnConflict = false)
        {
            foreach (var RinProcess in RinProcesses)
                _RinProcessBRL.UpdateRinProcess(RinProcess);

            var result = _RinProcessBRL.Save(continueOnConflict);
            _RinProcessBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinProcesses,
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
        public HttpResponseMessage DeleteRinProcesses(IEnumerable<tblICRinProcess> RinProcesses, bool continueOnConflict = false)
        {
            foreach (var RinProcess in RinProcesses)
                _RinProcessBRL.DeleteRinProcess(RinProcess);

            var result = _RinProcessBRL.Save(continueOnConflict);
            _RinProcessBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinProcesses,
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
