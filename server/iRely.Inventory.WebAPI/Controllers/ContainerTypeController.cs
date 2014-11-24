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
    public class ContainerTypeController : ApiController
    {
         private ContainerType _ContainerTypeBRL = new ContainerType();

        [HttpGet]
        public HttpResponseMessage SearchContainerTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICContainerType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICContainerType>(searchFilters);

            var data = _ContainerTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ContainerTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetContainerTypes")]
        public HttpResponseMessage GetContainerTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICContainerType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intContainerTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICContainerType>(searchFilters, true);

            var total = _ContainerTypeBRL.GetCount(predicate);
            var data = _ContainerTypeBRL.GetContainerTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostContainerTypes(IEnumerable<tblICContainerType> types, bool continueOnConflict = false)
        {
            foreach (var type in types)
                _ContainerTypeBRL.AddContainerType(type);

            var result = _ContainerTypeBRL.Save(continueOnConflict);
            _ContainerTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = types,
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
        public HttpResponseMessage PutContainerTypes(IEnumerable<tblICContainerType> types, bool continueOnConflict = false)
        {
            foreach (var type in types)
                _ContainerTypeBRL.UpdateContainerType(type);

            var result = _ContainerTypeBRL.Save(continueOnConflict);
            _ContainerTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = types,
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
        public HttpResponseMessage DeleteContainerTypes(IEnumerable<tblICContainerType> types, bool continueOnConflict = false)
        {
            foreach (var type in types)
                _ContainerTypeBRL.DeleteContainerType(type);

            var result = _ContainerTypeBRL.Save(continueOnConflict);
            _ContainerTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = types,
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
