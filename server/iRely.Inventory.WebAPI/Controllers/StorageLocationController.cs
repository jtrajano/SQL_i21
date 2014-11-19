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
    public class StorageLocationController : ApiController
    {

        private StorageLocation _StorageLocationBRL = new StorageLocation();

        [HttpGet]
        public HttpResponseMessage SearchStorageLocations(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStorageLocation>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStorageLocation>(searchFilters);

            var data = _StorageLocationBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _StorageLocationBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetStorageLocations")]
        public HttpResponseMessage GetStorageLocations(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStorageLocation>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intStorageLocationId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStorageLocation>(searchFilters, true);

            var total = _StorageLocationBRL.GetCount(predicate);
            var data = _StorageLocationBRL.GetStorageLocations(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostStorageLocations(IEnumerable<tblICStorageLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _StorageLocationBRL.AddStorageLocation(location);

            var result = _StorageLocationBRL.Save(continueOnConflict);
            _StorageLocationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
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
        public HttpResponseMessage PutStorageLocations(IEnumerable<tblICStorageLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _StorageLocationBRL.UpdateStorageLocation(location);

            var result = _StorageLocationBRL.Save(continueOnConflict);
            _StorageLocationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
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
        public HttpResponseMessage DeleteStorageLocations(IEnumerable<tblICStorageLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _StorageLocationBRL.DeleteStorageLocation(location);

            var result = _StorageLocationBRL.Save(continueOnConflict);
            _StorageLocationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
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
