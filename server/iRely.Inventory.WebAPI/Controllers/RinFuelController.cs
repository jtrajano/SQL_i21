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
    public class RinFuelController : ApiController
    {
        private RinFuel _RinFuelBRL = new RinFuel();

        [HttpGet]
        public HttpResponseMessage SearchRinFuels(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFuel>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFuel>(searchFilters);

            var data = _RinFuelBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _RinFuelBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRinFuels")]
        public HttpResponseMessage GetRinFuels(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFuel>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRinFuelId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFuel>(searchFilters, true);

            var total = _RinFuelBRL.GetCount(predicate);
            var data = _RinFuelBRL.GetRinFuels(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostRinFuels(IEnumerable<tblICRinFuel> RinFuels, bool continueOnConflict = false)
        {
            foreach (var RinFuel in RinFuels)
                _RinFuelBRL.AddRinFuel(RinFuel);

            var result = _RinFuelBRL.Save(continueOnConflict);
            _RinFuelBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFuels,
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
        public HttpResponseMessage PutRinFuels(IEnumerable<tblICRinFuel> RinFuels, bool continueOnConflict = false)
        {
            foreach (var RinFuel in RinFuels)
                _RinFuelBRL.UpdateRinFuel(RinFuel);

            var result = _RinFuelBRL.Save(continueOnConflict);
            _RinFuelBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFuels,
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
        public HttpResponseMessage DeleteRinFuels(IEnumerable<tblICRinFuel> RinFuels, bool continueOnConflict = false)
        {
            foreach (var RinFuel in RinFuels)
                _RinFuelBRL.DeleteRinFuel(RinFuel);

            var result = _RinFuelBRL.Save(continueOnConflict);
            _RinFuelBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFuels,
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
