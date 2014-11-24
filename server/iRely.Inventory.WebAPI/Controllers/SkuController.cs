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
    public class SkuController : ApiController
    {
         private Sku _SkuBRL = new Sku();

        [HttpGet]
        public HttpResponseMessage SearchSkus(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICSku>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICSku>(searchFilters);

            var data = _SkuBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _SkuBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetSkus")]
        public HttpResponseMessage GetSkus(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICSku>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intSkuId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICSku>(searchFilters, true);

            var total = _SkuBRL.GetCount(predicate);
            var data = _SkuBRL.GetSkus(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostSkus(IEnumerable<tblICSku> skus, bool continueOnConflict = false)
        {
            foreach (var sku in skus)
                _SkuBRL.AddSku(sku);

            var result = _SkuBRL.Save(continueOnConflict);
            _SkuBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = skus,
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
        public HttpResponseMessage PutSkus(IEnumerable<tblICSku> skus, bool continueOnConflict = false)
        {
            foreach (var sku in skus)
                _SkuBRL.UpdateSku(sku);

            var result = _SkuBRL.Save(continueOnConflict);
            _SkuBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = skus,
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
        public HttpResponseMessage DeleteSkus(IEnumerable<tblICSku> skus, bool continueOnConflict = false)
        {
            foreach (var sku in skus)
                _SkuBRL.DeleteSku(sku);

            var result = _SkuBRL.Save(continueOnConflict);
            _SkuBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = skus,
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
