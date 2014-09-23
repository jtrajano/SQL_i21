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
    public class RinFeedStockUOMController : ApiController
    {
        private RinFeedStockUOM _RinFeedStockUOMBRL = new RinFeedStockUOM();

        [HttpGet]
        public HttpResponseMessage SearchRinFeedStockUOMs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFeedStockUOM>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFeedStockUOM>(searchFilters);

            var data = _RinFeedStockUOMBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _RinFeedStockUOMBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRinFeedStockUOMs")]
        public HttpResponseMessage GetRinFeedStockUOMs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFeedStockUOM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRinFeedStockUOMId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFeedStockUOM>(searchFilters, true);

            var total = _RinFeedStockUOMBRL.GetCount(predicate);
            var data = _RinFeedStockUOMBRL.GetRinFeedStockUOMs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostRinFeedStockUOMs(IEnumerable<tblICRinFeedStockUOM> RinFeedStockUOMs, bool continueOnConflict = false)
        {
            foreach (var RinFeedStockUOM in RinFeedStockUOMs)
                _RinFeedStockUOMBRL.AddRinFeedStockUOM(RinFeedStockUOM);

            var result = _RinFeedStockUOMBRL.Save(continueOnConflict);
            _RinFeedStockUOMBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFeedStockUOMs,
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
        public HttpResponseMessage PutRinFeedStockUOMs(IEnumerable<tblICRinFeedStockUOM> RinFeedStockUOMs, bool continueOnConflict = false)
        {
            foreach (var RinFeedStockUOM in RinFeedStockUOMs)
                _RinFeedStockUOMBRL.UpdateRinFeedStockUOM(RinFeedStockUOM);

            var result = _RinFeedStockUOMBRL.Save(continueOnConflict);
            _RinFeedStockUOMBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFeedStockUOMs,
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
        public HttpResponseMessage DeleteRinFeedStockUOMs(IEnumerable<tblICRinFeedStockUOM> RinFeedStockUOMs, bool continueOnConflict = false)
        {
            foreach (var RinFeedStockUOM in RinFeedStockUOMs)
                _RinFeedStockUOMBRL.DeleteRinFeedStockUOM(RinFeedStockUOM);

            var result = _RinFeedStockUOMBRL.Save(continueOnConflict);
            _RinFeedStockUOMBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFeedStockUOMs,
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
