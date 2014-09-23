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
    public class FuelTypeController : ApiController
    {
        private FuelType _FuelTypeBRL = new FuelType();

        [HttpGet]
        public HttpResponseMessage SearchFuelTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICFuelType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICFuelType>(searchFilters);

            var data = _FuelTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _FuelTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetFuelTypes")]
        public HttpResponseMessage GetFuelTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICFuelType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intFuelTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICFuelType>(searchFilters, true);

            var total = _FuelTypeBRL.GetCount(predicate);
            var data = _FuelTypeBRL.GetFuelTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostFuelTypes(IEnumerable<tblICFuelType> FuelTypes, bool continueOnConflict = false)
        {
            foreach (var FuelType in FuelTypes)
                _FuelTypeBRL.AddFuelType(FuelType);

            var result = _FuelTypeBRL.Save(continueOnConflict);
            _FuelTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = FuelTypes,
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
        [HttpPost]
        [HttpPut]
        public HttpResponseMessage PutFuelTypes(IEnumerable<tblICFuelType> FuelTypes, bool continueOnConflict = false)
        {
            foreach (var FuelType in FuelTypes)
                _FuelTypeBRL.UpdateFuelType(FuelType);

            var result = _FuelTypeBRL.Save(continueOnConflict);
            _FuelTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = FuelTypes,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [AcceptVerbs("POST", "DELETE")]
        [HttpPost]
        [HttpDelete]
        public HttpResponseMessage DeleteFuelTypes(IEnumerable<tblICFuelType> FuelTypes, bool continueOnConflict = false)
        {
            foreach (var FuelType in FuelTypes)
                _FuelTypeBRL.DeleteFuelType(FuelType);

            var result = _FuelTypeBRL.Save(continueOnConflict);
            _FuelTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = FuelTypes,
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
