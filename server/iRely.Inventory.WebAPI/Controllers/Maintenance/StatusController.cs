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
    public class StatusController : ApiController
    {
         private Status _StatusBRL = new Status();

        [HttpGet]
        public HttpResponseMessage SearchStatuses(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStatus>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStatus>(searchFilters);

            var data = _StatusBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _StatusBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetStatuses")]
        public HttpResponseMessage GetStatuses(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStatus>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intStatusId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStatus>(searchFilters, true);

            var total = _StatusBRL.GetCount(predicate);
            var data = _StatusBRL.GetStatuses(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostStatuses(IEnumerable<tblICStatus> statuses, bool continueOnConflict = false)
        {
            foreach (var status in statuses)
                _StatusBRL.AddStatus(status);

            var result = _StatusBRL.Save(continueOnConflict);
            _StatusBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = statuses,
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
        public HttpResponseMessage PutStatuses(IEnumerable<tblICStatus> statuses, bool continueOnConflict = false)
        {
            foreach (var status in statuses)
                _StatusBRL.UpdateStatus(status);

            var result = _StatusBRL.Save(continueOnConflict);
            _StatusBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = statuses,
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
        public HttpResponseMessage DeleteStatuses(IEnumerable<tblICStatus> statuses, bool continueOnConflict = false)
        {
            foreach (var status in statuses)
                _StatusBRL.DeleteStatus(status);

            var result = _StatusBRL.Save(continueOnConflict);
            _StatusBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = statuses,
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
