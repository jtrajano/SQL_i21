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
    public class BrandController : ApiController
    {
         private Brand _BrandBRL = new Brand();

        [HttpGet]
        public HttpResponseMessage SearchBrands(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICBrand>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICBrand>(searchFilters);

            var data = _BrandBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _BrandBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetBrands")]
        public HttpResponseMessage GetBrands(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICBrand>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intBrandId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICBrand>(searchFilters, true);

            var total = _BrandBRL.GetCount(predicate);
            var data = _BrandBRL.GetBrands(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostBrands(IEnumerable<tblICBrand> brands, bool continueOnConflict = false)
        {
            foreach (var brand in brands)
                _BrandBRL.AddBrand(brand);

            var result = _BrandBRL.Save(continueOnConflict);
            _BrandBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = brands,
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
        public HttpResponseMessage PutBrands(IEnumerable<tblICBrand> brands, bool continueOnConflict = false)
        {
            foreach (var brand in brands)
                _BrandBRL.UpdateBrand(brand);

            var result = _BrandBRL.Save(continueOnConflict);
            _BrandBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = brands,
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
        public HttpResponseMessage DeleteBrands(IEnumerable<tblICBrand> brands, bool continueOnConflict = false)
        {
            foreach (var brand in brands)
                _BrandBRL.DeleteBrand(brand);

            var result = _BrandBRL.Save(continueOnConflict);
            _BrandBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = brands,
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
