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
    public class UnitTypeController : ApiController
    {
        private UnitType _UnitTypeBRL = new UnitType();

        public HttpResponseMessage SearchUnitTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICUnitType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICUnitType>(searchFilters);

            var data = _UnitTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _UnitTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetUnitTypes")]
        public HttpResponseMessage GetUnitTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICUnitType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intUnitTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICUnitType>(searchFilters, true);

            var total = _UnitTypeBRL.GetCount(predicate);
            var data = _UnitTypeBRL.GetUnitTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostUnitTypes(IEnumerable<tblICUnitType> UnitTypes, bool continueOnConflict = false)
        {
            foreach (var UnitType in UnitTypes)
                _UnitTypeBRL.AddUnitType(UnitType);

            var result = _UnitTypeBRL.Save(continueOnConflict);
            _UnitTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = UnitTypes,
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
        [HttpPut]
        public HttpResponseMessage PutUnitTypes(IEnumerable<tblICUnitType> UnitTypes, bool continueOnConflict = false)
        {
            foreach (var UnitType in UnitTypes)
                _UnitTypeBRL.UpdateUnitType(UnitType);

            var result = _UnitTypeBRL.Save(continueOnConflict);
            _UnitTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = UnitTypes,
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
        public HttpResponseMessage DeleteUnitTypes(IEnumerable<tblICUnitType> UnitTypes, bool continueOnConflict = false)
        {
            foreach (var UnitType in UnitTypes)
                _UnitTypeBRL.DeleteUnitType(UnitType);

            var result = _UnitTypeBRL.Save(continueOnConflict);
            _UnitTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = UnitTypes,
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
