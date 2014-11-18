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
    public class StorageUnitTypeController : ApiController
    {
        private StorageUnitType _StorageUnitTypeBRL = new StorageUnitType();

        [HttpGet]
        public HttpResponseMessage SearchStorageUnitTypes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStorageUnitType>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStorageUnitType>(searchFilters);

            var data = _StorageUnitTypeBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _StorageUnitTypeBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetStorageUnitTypes")]
        public HttpResponseMessage GetStorageUnitTypes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICStorageUnitType>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intStorageUnitTypeId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICStorageUnitType>(searchFilters, true);

            var total = _StorageUnitTypeBRL.GetCount(predicate);
            var data = _StorageUnitTypeBRL.GetStorageUnitTypes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostStorageUnitTypes(IEnumerable<tblICStorageUnitType> StorageUnitTypes, bool continueOnConflict = false)
        {
            foreach (var StorageUnitType in StorageUnitTypes)
                _StorageUnitTypeBRL.AddStorageUnitType(StorageUnitType);

            var result = _StorageUnitTypeBRL.Save(continueOnConflict);
            _StorageUnitTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = StorageUnitTypes,
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
        public HttpResponseMessage PutStorageUnitTypes(IEnumerable<tblICStorageUnitType> StorageUnitTypes, bool continueOnConflict = false)
        {
            foreach (var StorageUnitType in StorageUnitTypes)
                _StorageUnitTypeBRL.UpdateStorageUnitType(StorageUnitType);

            var result = _StorageUnitTypeBRL.Save(continueOnConflict);
            _StorageUnitTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = StorageUnitTypes,
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
        public HttpResponseMessage DeleteStorageUnitTypes(IEnumerable<tblICStorageUnitType> StorageUnitTypes, bool continueOnConflict = false)
        {
            foreach (var StorageUnitType in StorageUnitTypes)
                _StorageUnitTypeBRL.DeleteStorageUnitType(StorageUnitType);

            var result = _StorageUnitTypeBRL.Save(continueOnConflict);
            _StorageUnitTypeBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = StorageUnitTypes,
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
