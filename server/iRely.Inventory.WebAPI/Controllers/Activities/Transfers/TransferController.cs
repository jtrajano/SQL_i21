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
    public class TransferController : ApiController
    {
         private Transfer _TransferBRL = new Transfer();

        [HttpGet]
        public HttpResponseMessage SearchTransfers(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<TransferVM>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<TransferVM>(searchFilters);

            var data = _TransferBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _TransferBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetTransfers")]
        public HttpResponseMessage GetTransfers(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<TransferVM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intInventoryTransferId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<TransferVM>(searchFilters, true);

            var total = _TransferBRL.GetCount(predicate);
            var data = _TransferBRL.GetTransfers(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostTransfers(IEnumerable<tblICInventoryTransfer> transfers, bool continueOnConflict = false)
        {
            foreach (var transfer in transfers)
                _TransferBRL.AddTransfer(transfer);

            var result = _TransferBRL.Save(continueOnConflict);
            _TransferBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = transfers,
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
        public HttpResponseMessage PutTransfers(IEnumerable<tblICInventoryTransfer> transfers, bool continueOnConflict = false)
        {
            foreach (var transfer in transfers)
                _TransferBRL.UpdateTransfer(transfer);

            var result = _TransferBRL.Save(continueOnConflict);
            _TransferBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = transfers,
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
        public HttpResponseMessage DeleteTransfers(IEnumerable<tblICInventoryTransfer> transfers, bool continueOnConflict = false)
        {
            foreach (var transfer in transfers)
                _TransferBRL.DeleteTransfer(transfer);

            var result = _TransferBRL.Save(continueOnConflict);
            _TransferBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = transfers,
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
        public HttpResponseMessage Post(Inventory.BRL.Common.Posting_RequestModel transfer)
        {
            var result = _TransferBRL.PostTransaction(transfer, transfer.isRecap);
            _TransferBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = transfer,
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
