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
    public class ContainerController : ApiController
    {
        private Container _ContainerBRL = new Container();

        [HttpGet]
        public HttpResponseMessage SearchContainers(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICContainer>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICContainer>(searchFilters);

            var data = _ContainerBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ContainerBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetContainers")]
        public HttpResponseMessage GetContainers(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICContainer>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intContainerId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICContainer>(searchFilters, true);

            var total = _ContainerBRL.GetCount(predicate);
            var data = _ContainerBRL.GetContainers(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostContainers(IEnumerable<tblICContainer> containers, bool continueOnConflict = false)
        {
            foreach (var container in containers)
                _ContainerBRL.AddContainer(container);

            var result = _ContainerBRL.Save(continueOnConflict);
            _ContainerBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = containers,
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
        public HttpResponseMessage PutContainers(IEnumerable<tblICContainer> containers, bool continueOnConflict = false)
        {
            foreach (var container in containers)
                _ContainerBRL.UpdateContainer(container);

            var result = _ContainerBRL.Save(continueOnConflict);
            _ContainerBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = containers,
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
        public HttpResponseMessage DeleteContainers(IEnumerable<tblICContainer> containers, bool continueOnConflict = false)
        {
            foreach (var container in containers)
                _ContainerBRL.DeleteContainer(container);

            var result = _ContainerBRL.Save(continueOnConflict);
            _ContainerBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = containers,
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
