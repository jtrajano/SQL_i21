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
    public class ItemContractController : ApiController
    {
        private ItemContract _ItemContractBRL = new ItemContract();

        [HttpGet]
        public HttpResponseMessage SearchItemContracts(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemContract>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemContract>(searchFilters);

            var data = _ItemContractBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemContractBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemContracts")]
        public HttpResponseMessage GetItemContracts(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemContract>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemContractId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemContract>(searchFilters, true);

            var total = _ItemContractBRL.GetCount(predicate);
            var data = _ItemContractBRL.GetItemContracts(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemContracts(IEnumerable<tblICItemContract> contracts, bool continueOnConflict = false)
        {
            foreach (var contract in contracts)
                _ItemContractBRL.AddItemContract(contract);

            var result = _ItemContractBRL.Save(continueOnConflict);
            _ItemContractBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = contracts,
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
        public HttpResponseMessage PutItemContracts(IEnumerable<tblICItemContract> contracts, bool continueOnConflict = false)
        {
            foreach (var contract in contracts)
                _ItemContractBRL.UpdateItemContract(contract);

            var result = _ItemContractBRL.Save(continueOnConflict);
            _ItemContractBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = contracts,
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
        public HttpResponseMessage DeleteItemContracts(IEnumerable<tblICItemContract> contracts, bool continueOnConflict = false)
        {
            foreach (var contract in contracts)
                _ItemContractBRL.DeleteItemContract(contract);

            var result = _ItemContractBRL.Save(continueOnConflict);
            _ItemContractBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = contracts,
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
