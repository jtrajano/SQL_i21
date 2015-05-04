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
    public class BuildAssemblyController : ApiController
    {
         private BuildAssembly _BuildAssemblyBRL = new BuildAssembly();

        [HttpGet]
        public HttpResponseMessage SearchBuildAssemblies(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<BuildAssemblyVM>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<BuildAssemblyVM>(searchFilters);

            var data = _BuildAssemblyBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _BuildAssemblyBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetBuildAssemblies")]
        public HttpResponseMessage GetBuildAssemblies(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<BuildAssemblyVM>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intBuildAssemblyId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<BuildAssemblyVM>(searchFilters, true);

            var total = _BuildAssemblyBRL.GetCount(predicate);
            var data = _BuildAssemblyBRL.GetBuildAssemblies(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostBuildAssemblies(IEnumerable<tblICBuildAssembly> builds, bool continueOnConflict = false)
        {
            foreach (var build in builds)
                _BuildAssemblyBRL.AddBuildAssembly(build);

            var result = _BuildAssemblyBRL.Save(continueOnConflict);
            _BuildAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = builds,
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
        public HttpResponseMessage PutBuildAssemblies(IEnumerable<tblICBuildAssembly> builds, bool continueOnConflict = false)
        {
            foreach (var build in builds)
                _BuildAssemblyBRL.UpdateBuildAssembly(build);

            var result = _BuildAssemblyBRL.Save(continueOnConflict);
            _BuildAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = builds,
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
        public HttpResponseMessage DeleteBuildAssemblies(IEnumerable<tblICBuildAssembly> builds, bool continueOnConflict = false)
        {
            foreach (var build in builds)
                _BuildAssemblyBRL.DeleteBuildAssembly(build);

            var result = _BuildAssemblyBRL.Save(continueOnConflict);
            _BuildAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = builds,
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
        public HttpResponseMessage Post(Inventory.BRL.Common.Posting_RequestModel assembly)
        {
            var result = _BuildAssemblyBRL.PostTransaction(assembly, assembly.isRecap);
            _BuildAssemblyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = assembly,
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
