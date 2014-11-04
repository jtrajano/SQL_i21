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
    public class CatalogController : ApiController
    {

        private Catalog _CatalogBRL = new Catalog();

        [HttpGet]
        public HttpResponseMessage SearchCatalogs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCatalog>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCatalog>(searchFilters);

            var data = _CatalogBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CatalogBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCatalogs")]
        public HttpResponseMessage GetCatalogs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCatalog>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCatalogId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCatalog>(searchFilters, true);

            var total = _CatalogBRL.GetCount(predicate);
            var data = _CatalogBRL.GetCatalogs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCatalogsByParentId")]
        public HttpResponseMessage GetCatalogsByParentId(int ParentId = 0)
        {
            var total = _CatalogBRL.GetCount(p => p.intParentCatalogId == ParentId);
            var data = _CatalogBRL.GetCatalogs(ParentId);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                children = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCatalogs(IEnumerable<tblICCatalog> catalogs, bool continueOnConflict = false)
        {
            foreach (var catalog in catalogs)
                _CatalogBRL.AddCatalog(catalog);

            var result = _CatalogBRL.Save(continueOnConflict);
            _CatalogBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = catalogs,
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
        public HttpResponseMessage PutCatalogs(IEnumerable<tblICCatalog> catalogs, bool continueOnConflict = false)
        {
            foreach (var catalog in catalogs)
                _CatalogBRL.UpdateCatalog(catalog);

            var result = _CatalogBRL.Save(continueOnConflict);
            _CatalogBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = catalogs,
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
        public HttpResponseMessage DeleteCatalogs(IEnumerable<tblICCatalog> catalogs, bool continueOnConflict = false)
        {
            foreach (var catalog in catalogs)
                _CatalogBRL.DeleteCatalog(catalog);

            var result = _CatalogBRL.Save(continueOnConflict);
            _CatalogBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = catalogs,
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
