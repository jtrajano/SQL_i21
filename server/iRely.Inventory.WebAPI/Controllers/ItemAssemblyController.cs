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
    public class ItemAssemblyController : ApiController
    {
        private ItemAssembly _ItemAssemblyBRL = new ItemAssembly();

        [HttpGet]
        public HttpResponseMessage SearchItemAssemblies(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemAssembly>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemAssembly>(searchFilters);

            var data = _ItemAssemblyBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemAssemblyBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemAssemblies")]
        public HttpResponseMessage GetItemAssemblies(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemAssembly>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemAssemblyId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemAssembly>(searchFilters, true);

            var total = _ItemAssemblyBRL.GetCount(predicate);
            var data = _ItemAssemblyBRL.GetItemAssemblies(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemAssemblies(IEnumerable<tblICItemAssembly> assemblies, bool continueOnConflict = false)
        {
            foreach (var assembly in assemblies)
                _ItemAssemblyBRL.AddItemAssembly(assembly);

            var result = _ItemAssemblyBRL.Save(continueOnConflict);
            _ItemAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = assemblies,
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
        public HttpResponseMessage PutItemAssemblies(IEnumerable<tblICItemAssembly> assemblies, bool continueOnConflict = false)
        {
            foreach (var assembly in assemblies)
                _ItemAssemblyBRL.UpdateItemAssembly(assembly);

            var result = _ItemAssemblyBRL.Save(continueOnConflict);
            _ItemAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = assemblies,
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
        public HttpResponseMessage DeleteItemAssemblies(IEnumerable<tblICItemAssembly> assemblies, bool continueOnConflict = false)
        {
            foreach (var assembly in assemblies)
                _ItemAssemblyBRL.DeleteItemAssembly(assembly);

            var result = _ItemAssemblyBRL.Save(continueOnConflict);
            _ItemAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = assemblies,
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
