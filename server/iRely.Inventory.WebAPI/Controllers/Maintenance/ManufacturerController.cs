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
    public class ManufacturerController : ApiController
    {
        private Manufacturer _ManufacturerBRL = new Manufacturer();

        [HttpGet]
        public HttpResponseMessage SearchManufacturers(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICManufacturer>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICManufacturer>(searchFilters);

            var data = _ManufacturerBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ManufacturerBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetManufacturers")]
        public HttpResponseMessage GetManufacturers(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICManufacturer>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intManufacturerId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICManufacturer>(searchFilters, true);

            var total = _ManufacturerBRL.GetCount(predicate);
            var data = _ManufacturerBRL.GetManufacturers(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostManufacturers(IEnumerable<tblICManufacturer> Manufacturers, bool continueOnConflict = false)
        {
            foreach (var Manufacturer in Manufacturers)
                _ManufacturerBRL.AddManufacturer(Manufacturer);

            var result = _ManufacturerBRL.Save(continueOnConflict);
            _ManufacturerBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = Manufacturers,
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
        public HttpResponseMessage PutManufacturers(IEnumerable<tblICManufacturer> Manufacturers, bool continueOnConflict = false)
        {
            foreach (var Manufacturer in Manufacturers)
                _ManufacturerBRL.UpdateManufacturer(Manufacturer);

            var result = _ManufacturerBRL.Save(continueOnConflict);
            _ManufacturerBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = Manufacturers,
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
        public HttpResponseMessage DeleteManufacturers(IEnumerable<tblICManufacturer> Manufacturers, bool continueOnConflict = false)
        {
            foreach (var Manufacturer in Manufacturers)
                _ManufacturerBRL.DeleteManufacturer(Manufacturer);

            var result = _ManufacturerBRL.Save(continueOnConflict);
            _ManufacturerBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = Manufacturers,
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
