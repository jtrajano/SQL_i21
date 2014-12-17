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
    public class MaterialNMFCController : ApiController
    {
        private MaterialNMFC _MaterialNMFCBRL = new MaterialNMFC();

        [HttpGet]
        public HttpResponseMessage SearchMaterialNMFCs(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICMaterialNMFC>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICMaterialNMFC>(searchFilters);

            var data = _MaterialNMFCBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _MaterialNMFCBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetMaterialNMFCs")]
        public HttpResponseMessage GetMaterialNMFCs(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICMaterialNMFC>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intMaterialNMFCId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICMaterialNMFC>(searchFilters, true);

            var total = _MaterialNMFCBRL.GetCount(predicate);
            var data = _MaterialNMFCBRL.GetMaterialNMFCs(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostMaterialNMFCs(IEnumerable<tblICMaterialNMFC> materials, bool continueOnConflict = false)
        {
            foreach (var material in materials)
                _MaterialNMFCBRL.AddMaterialNMFC(material);

            var result = _MaterialNMFCBRL.Save(continueOnConflict);
            _MaterialNMFCBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = materials,
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
        public HttpResponseMessage PutMaterialNMFCs(IEnumerable<tblICMaterialNMFC> materials, bool continueOnConflict = false)
        {
            foreach (var material in materials)
                _MaterialNMFCBRL.UpdateMaterialNMFC(material);

            var result = _MaterialNMFCBRL.Save(continueOnConflict);
            _MaterialNMFCBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = materials,
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
        public HttpResponseMessage DeleteMaterialNMFCs(IEnumerable<tblICMaterialNMFC> materials, bool continueOnConflict = false)
        {
            foreach (var material in materials)
                _MaterialNMFCBRL.DeleteMaterialNMFC(material);

            var result = _MaterialNMFCBRL.Save(continueOnConflict);
            _MaterialNMFCBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = materials,
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
