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
    public class ItemCertificationController : ApiController
    {
        private ItemCertification _ItemCertificationBRL = new ItemCertification();

        [HttpGet]
        public HttpResponseMessage SearchItemCertifications(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemCertification>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemCertification>(searchFilters);

            var data = _ItemCertificationBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemCertificationBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemCertifications")]
        public HttpResponseMessage GetItemCertifications(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemCertification>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemCertificationId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemCertification>(searchFilters, true);

            var total = _ItemCertificationBRL.GetCount(predicate);
            var data = _ItemCertificationBRL.GetItemCertifications(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemCertifications(IEnumerable<tblICItemCertification> certificates, bool continueOnConflict = false)
        {
            foreach (var certificate in certificates)
                _ItemCertificationBRL.AddItemCertification(certificate);

            var result = _ItemCertificationBRL.Save(continueOnConflict);
            _ItemCertificationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = certificates,
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
        public HttpResponseMessage PutItemCertifications(IEnumerable<tblICItemCertification> certificates, bool continueOnConflict = false)
        {
            foreach (var certificate in certificates)
                _ItemCertificationBRL.UpdateItemCertification(certificate);

            var result = _ItemCertificationBRL.Save(continueOnConflict);
            _ItemCertificationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = certificates,
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
        public HttpResponseMessage DeleteItemCertifications(IEnumerable<tblICItemCertification> certificates, bool continueOnConflict = false)
        {
            foreach (var certificate in certificates)
                _ItemCertificationBRL.DeleteItemCertification(certificate);

            var result = _ItemCertificationBRL.Save(continueOnConflict);
            _ItemCertificationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = certificates,
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
