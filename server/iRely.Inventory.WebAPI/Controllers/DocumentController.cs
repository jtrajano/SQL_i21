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
    public class DocumentController : ApiController
    {

        private Document _DocumentBRL = new Document();

        [HttpGet]
        public HttpResponseMessage SearchBrands(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICDocument>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICDocument>(searchFilters);

            var data = _DocumentBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _DocumentBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetDocuments")]
        public HttpResponseMessage GetDocuments(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICDocument>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intDocumentId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICDocument>(searchFilters, true);

            var total = _DocumentBRL.GetCount(predicate);
            var data = _DocumentBRL.GetDocuments(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostDocuments(IEnumerable<tblICDocument> documents, bool continueOnConflict = false)
        {
            foreach (var doc in documents)
                _DocumentBRL.AddDocument(doc);

            var result = _DocumentBRL.Save(continueOnConflict);
            _DocumentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = documents,
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
        public HttpResponseMessage PutDocuments(IEnumerable<tblICDocument> documents, bool continueOnConflict = false)
        {
            foreach (var doc in documents)
                _DocumentBRL.UpdateDocument(doc);

            var result = _DocumentBRL.Save(continueOnConflict);
            _DocumentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = documents,
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
        public HttpResponseMessage DeleteDocuments(IEnumerable<tblICDocument> documents, bool continueOnConflict = false)
        {
            foreach (var doc in documents)
                _DocumentBRL.DeleteDocument(doc);

            var result = _DocumentBRL.Save(continueOnConflict);
            _DocumentBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = documents,
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
