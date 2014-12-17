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
    public class ReceiptItemTaxController : ApiController
    {

        private ReceiptItemTax _ReceiptItemTaxBRL = new ReceiptItemTax();

        [HttpGet]
        public HttpResponseMessage SearchReceiptItemTaxes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICInventoryReceiptItemTax>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICInventoryReceiptItemTax>(searchFilters);

            var data = _ReceiptItemTaxBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ReceiptItemTaxBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetReceiptItemTaxes")]
        public HttpResponseMessage GetReceiptItemTaxes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICInventoryReceiptItemTax>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intInventoryReceiptItemTaxId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICInventoryReceiptItemTax>(searchFilters, true);

            var total = _ReceiptItemTaxBRL.GetCount(predicate);
            var data = _ReceiptItemTaxBRL.GetReceiptItemTaxes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostReceiptItemTaxes(IEnumerable<tblICInventoryReceiptItemTax> taxes, bool continueOnConflict = false)
        {
            foreach (var tax in taxes)
                _ReceiptItemTaxBRL.AddReceiptItemTax(tax);

            var result = _ReceiptItemTaxBRL.Save(continueOnConflict);
            _ReceiptItemTaxBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = taxes,
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
        public HttpResponseMessage PutReceiptItemTaxes(IEnumerable<tblICInventoryReceiptItemTax> taxes, bool continueOnConflict = false)
        {
            foreach (var tax in taxes)
                _ReceiptItemTaxBRL.UpdateReceiptItemTax(tax);

            var result = _ReceiptItemTaxBRL.Save(continueOnConflict);
            _ReceiptItemTaxBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = taxes,
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
        public HttpResponseMessage DeleteReceiptItemTaxes(IEnumerable<tblICInventoryReceiptItemTax> taxes, bool continueOnConflict = false)
        {
            foreach (var tax in taxes)
                _ReceiptItemTaxBRL.DeleteReceiptItemTax(tax);

            var result = _ReceiptItemTaxBRL.Save(continueOnConflict);
            _ReceiptItemTaxBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = taxes,
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
