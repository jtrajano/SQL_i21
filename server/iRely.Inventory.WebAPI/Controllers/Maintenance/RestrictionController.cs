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
    public class RestrictionController : ApiController
    {
         private Restriction _RestrictionBRL = new Restriction();

        [HttpGet]
        public HttpResponseMessage SearchRestrictions(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRestriction>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRestriction>(searchFilters);

            var data = _RestrictionBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _RestrictionBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetRestrictions")]
        public HttpResponseMessage GetRestrictions(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICRestriction>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRestrictionId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICRestriction>(searchFilters, true);

            var total = _RestrictionBRL.GetCount(predicate);
            var data = _RestrictionBRL.GetRestrictions(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostRestrictions(IEnumerable<tblICRestriction> restrictions, bool continueOnConflict = false)
        {
            foreach (var restriction in restrictions)
                _RestrictionBRL.AddRestriction(restriction);

            var result = _RestrictionBRL.Save(continueOnConflict);
            _RestrictionBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = restrictions,
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
        public HttpResponseMessage PutRestrictions(IEnumerable<tblICRestriction> restrictions, bool continueOnConflict = false)
        {
            foreach (var restriction in restrictions)
                _RestrictionBRL.UpdateRestriction(restriction);

            var result = _RestrictionBRL.Save(continueOnConflict);
            _RestrictionBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = restrictions,
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
        public HttpResponseMessage DeleteRestrictions(IEnumerable<tblICRestriction> restrictions, bool continueOnConflict = false)
        {
            foreach (var restriction in restrictions)
                _RestrictionBRL.DeleteRestriction(restriction);

            var result = _RestrictionBRL.Save(continueOnConflict);
            _RestrictionBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = restrictions,
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
