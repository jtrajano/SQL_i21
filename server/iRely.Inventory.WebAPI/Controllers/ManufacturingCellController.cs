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
    public class ManufacturingCellController : ApiController
    {

        private ManufacturingCell _ManufacturingCellBRL = new ManufacturingCell();

        [HttpGet]
        public HttpResponseMessage SearchManufacturingCells(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICManufacturingCell>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICManufacturingCell>(searchFilters);

            var data = _ManufacturingCellBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ManufacturingCellBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetManufacturingCells")]
        public HttpResponseMessage GetManufacturingCells(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICManufacturingCell>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intManufacturingCellId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICManufacturingCell>(searchFilters, true);

            var total = _ManufacturingCellBRL.GetCount(predicate);
            var data = _ManufacturingCellBRL.GetManufacturingCells(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostManufacturingCells(IEnumerable<tblICManufacturingCell> cells, bool continueOnConflict = false)
        {
            foreach (var cell in cells)
                _ManufacturingCellBRL.AddManufacturingCell(cell);

            var result = _ManufacturingCellBRL.Save(continueOnConflict);
            _ManufacturingCellBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = cells,
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
        public HttpResponseMessage PutManufacturingCells(IEnumerable<tblICManufacturingCell> cells, bool continueOnConflict = false)
        {
            foreach (var cell in cells)
                _ManufacturingCellBRL.UpdateManufacturingCell(cell);

            var result = _ManufacturingCellBRL.Save(continueOnConflict);
            _ManufacturingCellBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = cells,
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
        public HttpResponseMessage DeleteManufacturingCells(IEnumerable<tblICManufacturingCell> cells, bool continueOnConflict = false)
        {
            foreach (var cell in cells)
                _ManufacturingCellBRL.DeleteManufacturingCell(cell);

            var result = _ManufacturingCellBRL.Save(continueOnConflict);
            _ManufacturingCellBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = cells,
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
