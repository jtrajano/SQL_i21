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
    public class FuelTaxClassController : ApiController
    {
        private FuelTaxClass _FuelTaxClassBRL = new FuelTaxClass();

        [HttpGet]
        public HttpResponseMessage SearchFuelTaxClasss(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICFuelTaxClass>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICFuelTaxClass>(searchFilters);

            var data = _FuelTaxClassBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _FuelTaxClassBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetFuelTaxClasses")]
        public HttpResponseMessage GetFuelTaxClasses(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICFuelTaxClass>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intFuelTaxClassId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICFuelTaxClass>(searchFilters, true);

            var total = _FuelTaxClassBRL.GetCount(predicate);
            var data = _FuelTaxClassBRL.GetTaxClasses(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostFuelTaxClasss(IEnumerable<tblICFuelTaxClass> taxclasses, bool continueOnConflict = false)
        {
            foreach (var taxclass in taxclasses)
                _FuelTaxClassBRL.AddTaxClass(taxclass);

            var result = _FuelTaxClassBRL.Save(continueOnConflict);
            _FuelTaxClassBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = taxclasses,
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
        public HttpResponseMessage PutFuelTaxClasss(IEnumerable<tblICFuelTaxClass> taxclasses, bool continueOnConflict = false)
        {
            foreach (var taxclass in taxclasses)
                _FuelTaxClassBRL.UpdateTaxClass(taxclass);

            var result = _FuelTaxClassBRL.Save(continueOnConflict);
            _FuelTaxClassBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = taxclasses,
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
        public HttpResponseMessage DeleteFuelTaxClasss(IEnumerable<tblICFuelTaxClass> taxclasses, bool continueOnConflict = false)
        {
            foreach (var taxclass in taxclasses)
                _FuelTaxClassBRL.DeleteTaxClass(taxclass);

            var result = _FuelTaxClassBRL.Save(continueOnConflict);
            _FuelTaxClassBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = taxclasses,
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
