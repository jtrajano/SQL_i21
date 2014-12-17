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
    public class LotStatusController : ApiController
    {

        private LotStatus _LotStatusBRL = new LotStatus();

        [HttpGet]
        public HttpResponseMessage SearchLotStatuses(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICLotStatus>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICLotStatus>(searchFilters);

            var data = _LotStatusBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _LotStatusBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetLotStatuses")]
        public HttpResponseMessage GetLotStatuses(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICLotStatus>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intLotStatusId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICLotStatus>(searchFilters, true);

            var total = _LotStatusBRL.GetCount(predicate);
            var data = _LotStatusBRL.GetLotStatuses(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostLotStatuses(IEnumerable<tblICLotStatus> statuss, bool continueOnConflict = false)
        {
            foreach (var status in statuss)
                _LotStatusBRL.AddLotStatus(status);

            var result = _LotStatusBRL.Save(continueOnConflict);
            _LotStatusBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = statuss,
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
        public HttpResponseMessage PutLotStatuses(IEnumerable<tblICLotStatus> statuss, bool continueOnConflict = false)
        {
            foreach (var status in statuss)
                _LotStatusBRL.UpdateLotStatus(status);

            var result = _LotStatusBRL.Save(continueOnConflict);
            _LotStatusBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = statuss,
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
        public HttpResponseMessage DeleteLotStatuses(IEnumerable<tblICLotStatus> statuss, bool continueOnConflict = false)
        {
            foreach (var status in statuss)
                _LotStatusBRL.DeleteLotStatus(status);

            var result = _LotStatusBRL.Save(continueOnConflict);
            _LotStatusBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = statuss,
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
