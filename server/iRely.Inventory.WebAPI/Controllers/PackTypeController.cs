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
    public class PackTypeController : ApiController
    {

        private PackType _PackTypeBRL = new PackType();

        [HttpGet]
        public HttpResponseMessage SearchPackTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICPackType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICPackType>(searchFilters);

            var data = _PackTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _PackTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetPackTypes")]
        public HttpResponseMessage GetPackTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICPackType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intPackTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICPackType>(searchFilters, true);

            var total = _PackTypeBRL.GetCount(predicate);
            var data = _PackTypeBRL.GetPackTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostPackTypes(IEnumerable<tblICPackType> packtypes, bool continueOnConflict = false)
        {
            foreach (var packtype in packtypes)
                _PackTypeBRL.AddPackType(packtype);

            var result = _PackTypeBRL.Save(continueOnConflict);
            _PackTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = packtypes,
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
        public HttpResponseMessage PutPackTypes(IEnumerable<tblICPackType> packtypes, bool continueOnConflict = false)
        {
            foreach (var packtype in packtypes)
                _PackTypeBRL.UpdatePackType(packtype);

            var result = _PackTypeBRL.Save(continueOnConflict);
            _PackTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = packtypes,
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
        public HttpResponseMessage DeletePackTypes(IEnumerable<tblICPackType> packtypes, bool continueOnConflict = false)
        {
            foreach (var packtype in packtypes)
                _PackTypeBRL.DeletePackType(packtype);

            var result = _PackTypeBRL.Save(continueOnConflict);
            _PackTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = packtypes,
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
