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
    public class ReceiptController : ApiController
    {

        private Receipt _ReceiptBRL = new Receipt();

        [HttpGet]
        public HttpResponseMessage SearchReceipts(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<vyuReciepts>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<vyuReciepts>(searchFilters);

            var data = _ReceiptBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ReceiptBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetReceipts")]
        public HttpResponseMessage GetReceipts(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<vyuReciepts>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intInventoryReceiptId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<vyuReciepts>(searchFilters, true);

            var total = _ReceiptBRL.GetCount(predicate);
            var data = _ReceiptBRL.GetReceipts(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostReceipts(IEnumerable<tblICInventoryReceipt> receipts, bool continueOnConflict = false)
        {
            foreach (var receipt in receipts)
                _ReceiptBRL.AddReceipt(receipt);

            var result = _ReceiptBRL.Save(continueOnConflict);
            _ReceiptBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = receipts,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }


        [HttpPost]
        public HttpResponseMessage Receive(Inventory.BRL.Common.Posting_RequestModel receipt)
        {
            var result = _ReceiptBRL.PostTransaction(receipt, receipt.isRecap);
            _ReceiptBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = receipt,
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
        public HttpResponseMessage PutReceipts(IEnumerable<tblICInventoryReceipt> receipts, bool continueOnConflict = false)
        {
            foreach (var receipt in receipts)
                _ReceiptBRL.UpdateReceipt(receipt);

            var result = _ReceiptBRL.Save(continueOnConflict);
            _ReceiptBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = receipts,
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
        public HttpResponseMessage DeleteReceipts(IEnumerable<tblICInventoryReceipt> receipts, bool continueOnConflict = false)
        {
            foreach (var receipt in receipts)
                _ReceiptBRL.DeleteReceipt(receipt);

            var result = _ReceiptBRL.Save(continueOnConflict);
            _ReceiptBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = receipts,
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
