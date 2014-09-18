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
    public class RinFuelTypeController : ApiController
    {
        private RinFuelType _RinFuelTypeBRL = new RinFuelType();

        [HttpGet]
        public HttpResponseMessage SearchRinFuelTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFuelType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFuelType>(searchFilters);

            var data = _RinFuelTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _RinFuelTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRinFuelTypes")]
        public HttpResponseMessage GetRinFuelTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRinFuelType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRinFuelTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRinFuelType>(searchFilters, true);

            var total = _RinFuelTypeBRL.GetCount(predicate);
            var data = _RinFuelTypeBRL.GetRinFuelTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostRinFuelTypes(IEnumerable<tblICRinFuelType> RinFuelTypes, bool continueOnConflict = false)
        {
            foreach (var RinFuelType in RinFuelTypes)
                _RinFuelTypeBRL.AddRinFuelType(RinFuelType);

            var result = _RinFuelTypeBRL.Save(continueOnConflict);
            _RinFuelTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFuelTypes,
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
        public HttpResponseMessage PutRinFuelTypes(IEnumerable<tblICRinFuelType> RinFuelTypes, bool continueOnConflict = false)
        {
            foreach (var RinFuelType in RinFuelTypes)
                _RinFuelTypeBRL.UpdateRinFuelType(RinFuelType);

            var result = _RinFuelTypeBRL.Save(continueOnConflict);
            _RinFuelTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFuelTypes,
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
        public HttpResponseMessage DeleteRinFuelTypes(IEnumerable<tblICRinFuelType> RinFuelTypes, bool continueOnConflict = false)
        {
            foreach (var RinFuelType in RinFuelTypes)
                _RinFuelTypeBRL.DeleteRinFuelType(RinFuelType);

            var result = _RinFuelTypeBRL.Save(continueOnConflict);
            _RinFuelTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = RinFuelTypes,
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
