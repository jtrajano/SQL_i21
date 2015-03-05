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
    public class ItemLocationController : ApiController
    {
        private ItemLocation _ItemLocationBRL = new ItemLocation();

        [HttpGet]
        public HttpResponseMessage SearchItemLocations(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemLocation>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemLocation>(searchFilters);

            var data = _ItemLocationBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemLocationBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemLocations")]
        public HttpResponseMessage GetItemLocations(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemLocation>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemLocationId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemLocation>(searchFilters, true);

            var total = _ItemLocationBRL.GetCount(predicate);
            var data = _ItemLocationBRL.GetItemLocations(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemLocations(IEnumerable<tblICItemLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _ItemLocationBRL.AddItemLocation(location);

            var result = _ItemLocationBRL.Save(continueOnConflict);
            _ItemLocationBRL.Dispose();

            var errMessage = result.Exception.Message;
            if (result.BaseException != null)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemLocation'"))
                {
                    errMessage = "Location already exist for this Item.";
                }
            }

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = locations,
                success = !result.HasError,
                message = new
                {
                    statusText = errMessage,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpPut]
        public HttpResponseMessage PutItemLocations(IEnumerable<tblICItemLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _ItemLocationBRL.UpdateItemLocation(location);

            var result = _ItemLocationBRL.Save(continueOnConflict);
            _ItemLocationBRL.Dispose();

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
        public HttpResponseMessage DeleteItemLocations(IEnumerable<tblICItemLocation> locations, bool continueOnConflict = false)
        {
            foreach (var location in locations)
                _ItemLocationBRL.DeleteItemLocation(location);

            var result = _ItemLocationBRL.Save(continueOnConflict);
            _ItemLocationBRL.Dispose();

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
