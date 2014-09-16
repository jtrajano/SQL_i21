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
    public class TagController : ApiController
    {
        private Tag _TagBRL = new Tag();

        public HttpResponseMessage SearchTags(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICTag>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICTag>(searchFilters);

            var data = _TagBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _TagBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetTags")]
        public HttpResponseMessage GetTags(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICTag>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intTagId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICTag>(searchFilters, true);

            var total = _TagBRL.GetCount(predicate);
            var data = _TagBRL.GetTags(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostTags(IEnumerable<tblICTag> tags, bool continueOnConflict = false)
        {
            foreach (var tag in tags)
                _TagBRL.AddTag(tag);

            var result = _TagBRL.Save(continueOnConflict);
            _TagBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = tags,
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
        public HttpResponseMessage PutTags(IEnumerable<tblICTag> tags, bool continueOnConflict = false)
        {
            foreach (var tag in tags)
                _TagBRL.UpdateTag(tag);

            var result = _TagBRL.Save(continueOnConflict);
            _TagBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = tags,
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
        public HttpResponseMessage DeleteTags(IEnumerable<tblICTag> tags, bool continueOnConflict = false)
        {
            foreach (var tag in tags)
                _TagBRL.DeleteTag(tag);

            var result = _TagBRL.Save(continueOnConflict);
            _TagBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = tags,
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
