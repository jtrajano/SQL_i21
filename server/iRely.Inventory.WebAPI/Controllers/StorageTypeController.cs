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
    public class StorageTypeController : ApiController
    {

        private StorageType _StorageTypeBRL = new StorageType();

        [HttpGet]
        public HttpResponseMessage SearchStorageTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblGRStorageType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblGRStorageType>(searchFilters);

            var data = _StorageTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _StorageTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetStorageTypes")]
        public HttpResponseMessage GetStorageTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblGRStorageType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intStorageTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblGRStorageType>(searchFilters, true);

            var total = _StorageTypeBRL.GetCount(predicate);
            var data = _StorageTypeBRL.GetStorageTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostStorageTypes(IEnumerable<tblGRStorageType> types, bool continueOnConflict = false)
        {
            foreach (var type in types)
                _StorageTypeBRL.AddStorageType(type);

            var result = _StorageTypeBRL.Save(continueOnConflict);
            _StorageTypeBRL.Dispose();

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
        public HttpResponseMessage PutStorageTypes(IEnumerable<tblGRStorageType> types, bool continueOnConflict = false)
        {
            foreach (var type in types)
                _StorageTypeBRL.UpdateStorageType(type);

            var result = _StorageTypeBRL.Save(continueOnConflict);
            _StorageTypeBRL.Dispose();

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
        public HttpResponseMessage DeleteStorageTypes(IEnumerable<tblGRStorageType> types, bool continueOnConflict = false)
        {
            foreach (var type in types)
                _StorageTypeBRL.DeleteStorageType(type);

            var result = _StorageTypeBRL.Save(continueOnConflict);
            _StorageTypeBRL.Dispose();

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
