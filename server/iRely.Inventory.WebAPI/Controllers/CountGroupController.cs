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
    public class CountGroupController : ApiController
    {
        private CountGroup _CountGroupBRL = new CountGroup();

        [HttpGet]
        public HttpResponseMessage SearchCountGroups(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCountGroup>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCountGroup>(searchFilters);

            var data = _CountGroupBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CountGroupBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCountGroups")]
        public HttpResponseMessage GetCountGroups(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCountGroup>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCountGroupId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCountGroup>(searchFilters, true);

            var total = _CountGroupBRL.GetCount(predicate);
            var data = _CountGroupBRL.GetCountGroups(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCountGroups(IEnumerable<tblICCountGroup> groups, bool continueOnConflict = false)
        {
            foreach (var group in groups)
                _CountGroupBRL.AddCountGroup(group);

            var result = _CountGroupBRL.Save(continueOnConflict);
            _CountGroupBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = groups,
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
        public HttpResponseMessage PutCountGroups(IEnumerable<tblICCountGroup> groups, bool continueOnConflict = false)
        {
            foreach (var group in groups)
                _CountGroupBRL.UpdateCountGroup(group);

            var result = _CountGroupBRL.Save(continueOnConflict);
            _CountGroupBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = groups,
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
        public HttpResponseMessage DeleteCountGroups(IEnumerable<tblICCountGroup> groups, bool continueOnConflict = false)
        {
            foreach (var group in groups)
                _CountGroupBRL.DeleteCountGroup(group);

            var result = _CountGroupBRL.Save(continueOnConflict);
            _CountGroupBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = groups,
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
