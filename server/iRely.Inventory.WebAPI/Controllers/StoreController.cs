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
    public class StoreController : ApiController
    {

        private Store _StoreBRL = new Store();

        [HttpGet]
        public HttpResponseMessage SearchStores(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTStore>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTStore>(searchFilters);

            var data = _StoreBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _StoreBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetStores")]
        public HttpResponseMessage GetStores(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTStore>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intStoreId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTStore>(searchFilters, true);

            var total = _StoreBRL.GetCount(predicate);
            var data = _StoreBRL.GetStores(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostStores(IEnumerable<tblSTStore> stores, bool continueOnConflict = false)
        {
            foreach (var store in stores)
                _StoreBRL.AddStore(store);

            var result = _StoreBRL.Save(continueOnConflict);
            _StoreBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = stores,
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
        public HttpResponseMessage PutStores(IEnumerable<tblSTStore> stores, bool continueOnConflict = false)
        {
            foreach (var store in stores)
                _StoreBRL.UpdateStore(store);

            var result = _StoreBRL.Save(continueOnConflict);
            _StoreBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = stores,
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
        public HttpResponseMessage DeleteStores(IEnumerable<tblSTStore> stores, bool continueOnConflict = false)
        {
            foreach (var store in stores)
                _StoreBRL.DeleteStore(store);

            var result = _StoreBRL.Save(continueOnConflict);
            _StoreBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = stores,
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

    public class PaidOutController : ApiController
    {

        private PaidOut _PaidOutBRL = new PaidOut();

        [HttpGet]
        public HttpResponseMessage SearchPaidOuts(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTPaidOut>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTPaidOut>(searchFilters);

            var data = _PaidOutBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _PaidOutBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetPaidOuts")]
        public HttpResponseMessage GetPaidOuts(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTPaidOut>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intPaidOutId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTPaidOut>(searchFilters, true);

            var total = _PaidOutBRL.GetCount(predicate);
            var data = _PaidOutBRL.GetPaidOuts(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostPaidOuts(IEnumerable<tblSTPaidOut> paidouts, bool continueOnConflict = false)
        {
            foreach (var paidout in paidouts)
                _PaidOutBRL.AddPaidOut(paidout);

            var result = _PaidOutBRL.Save(continueOnConflict);
            _PaidOutBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = paidouts,
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
        public HttpResponseMessage PutPaidOuts(IEnumerable<tblSTPaidOut> paidouts, bool continueOnConflict = false)
        {
            foreach (var paidout in paidouts)
                _PaidOutBRL.UpdatePaidOut(paidout);

            var result = _PaidOutBRL.Save(continueOnConflict);
            _PaidOutBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = paidouts,
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
        public HttpResponseMessage DeletePaidOuts(IEnumerable<tblSTPaidOut> paidouts, bool continueOnConflict = false)
        {
            foreach (var paidout in paidouts)
                _PaidOutBRL.DeletePaidOut(paidout);

            var result = _PaidOutBRL.Save(continueOnConflict);
            _PaidOutBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = paidouts,
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

    public class SubcategoryClassController : ApiController
    {

        private SubcategoryClass _SubcategoryClassBRL = new SubcategoryClass();

        [HttpGet]
        public HttpResponseMessage SearchSubcategoryClasses(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTSubcategoryClass>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTSubcategoryClass>(searchFilters);

            var data = _SubcategoryClassBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _SubcategoryClassBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetSubcategoryClasses")]
        public HttpResponseMessage GetSubcategoryClasses(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTSubcategoryClass>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intClassId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTSubcategoryClass>(searchFilters, true);

            var total = _SubcategoryClassBRL.GetCount(predicate);
            var data = _SubcategoryClassBRL.GetSubcategoryClasss(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostSubcategoryClasses(IEnumerable<tblSTSubcategoryClass> subcategoryclasses, bool continueOnConflict = false)
        {
            foreach (var subcategoryclass in subcategoryclasses)
                _SubcategoryClassBRL.AddSubcategoryClass(subcategoryclass);

            var result = _SubcategoryClassBRL.Save(continueOnConflict);
            _SubcategoryClassBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = subcategoryclasses,
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
        public HttpResponseMessage PutSubcategoryClasses(IEnumerable<tblSTSubcategoryClass> subcategoryclasses, bool continueOnConflict = false)
        {
            foreach (var subcategoryclass in subcategoryclasses)
                _SubcategoryClassBRL.UpdateSubcategoryClass(subcategoryclass);

            var result = _SubcategoryClassBRL.Save(continueOnConflict);
            _SubcategoryClassBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = subcategoryclasses,
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
        public HttpResponseMessage DeleteSubcategoryClasses(IEnumerable<tblSTSubcategoryClass> subcategoryclasses, bool continueOnConflict = false)
        {
            foreach (var subcategoryclass in subcategoryclasses)
                _SubcategoryClassBRL.DeleteSubcategoryClass(subcategoryclass);

            var result = _SubcategoryClassBRL.Save(continueOnConflict);
            _SubcategoryClassBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = subcategoryclasses,
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

    public class SubcategoryFamilyController : ApiController
    {

        private SubcategoryFamily _SubcategoryFamilyBRL = new SubcategoryFamily();

        [HttpGet]
        public HttpResponseMessage SearchSubcategoryFamilies(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTSubcategoryFamily>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTSubcategoryFamily>(searchFilters);

            var data = _SubcategoryFamilyBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _SubcategoryFamilyBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetSubcategoryFamilies")]
        public HttpResponseMessage GetSubcategoryFamilies(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTSubcategoryFamily>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intFamilyId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTSubcategoryFamily>(searchFilters, true);

            var total = _SubcategoryFamilyBRL.GetCount(predicate);
            var data = _SubcategoryFamilyBRL.GetSubcategoryFamilys(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostSubcategoryFamilies(IEnumerable<tblSTSubcategoryFamily> families, bool continueOnConflict = false)
        {
            foreach (var family in families)
                _SubcategoryFamilyBRL.AddSubcategoryFamily(family);

            var result = _SubcategoryFamilyBRL.Save(continueOnConflict);
            _SubcategoryFamilyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = families,
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
        public HttpResponseMessage PutSubcategoryFamilies(IEnumerable<tblSTSubcategoryFamily> families, bool continueOnConflict = false)
        {
            foreach (var family in families)
                _SubcategoryFamilyBRL.UpdateSubcategoryFamily(family);

            var result = _SubcategoryFamilyBRL.Save(continueOnConflict);
            _SubcategoryFamilyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = families,
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
        public HttpResponseMessage DeleteSubcategoryFamilies(IEnumerable<tblSTSubcategoryFamily> families, bool continueOnConflict = false)
        {
            foreach (var family in families)
                _SubcategoryFamilyBRL.DeleteSubcategoryFamily(family);

            var result = _SubcategoryFamilyBRL.Save(continueOnConflict);
            _SubcategoryFamilyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = families,
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

    public class SubcategoryRegProdController : ApiController
    {

        private SubcategoryRegProd _SubcategoryRegProdBRL = new SubcategoryRegProd();

        [HttpGet]
        public HttpResponseMessage SearchSubcategoryRegProds(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTSubcategoryRegProd>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTSubcategoryRegProd>(searchFilters);

            var data = _SubcategoryRegProdBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _SubcategoryRegProdBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetSubcategoryRegProds")]
        public HttpResponseMessage GetSubcategoryRegProds(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblSTSubcategoryRegProd>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intRegProdId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblSTSubcategoryRegProd>(searchFilters, true);

            var total = _SubcategoryRegProdBRL.GetCount(predicate);
            var data = _SubcategoryRegProdBRL.GetSubcategoryRegProds(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostSubcategoryRegProds(IEnumerable<tblSTSubcategoryRegProd> products, bool continueOnConflict = false)
        {
            foreach (var product in products)
                _SubcategoryRegProdBRL.AddSubcategoryRegProd(product);

            var result = _SubcategoryRegProdBRL.Save(continueOnConflict);
            _SubcategoryRegProdBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = products,
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
        public HttpResponseMessage PutSubcategoryRegProds(IEnumerable<tblSTSubcategoryRegProd> products, bool continueOnConflict = false)
        {
            foreach (var product in products)
                _SubcategoryRegProdBRL.UpdateSubcategoryRegProd(product);

            var result = _SubcategoryRegProdBRL.Save(continueOnConflict);
            _SubcategoryRegProdBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = products,
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
        public HttpResponseMessage DeleteSubcategoryRegProds(IEnumerable<tblSTSubcategoryRegProd> products, bool continueOnConflict = false)
        {
            foreach (var product in products)
                _SubcategoryRegProdBRL.DeleteSubcategoryRegProd(product);

            var result = _SubcategoryRegProdBRL.Save(continueOnConflict);
            _SubcategoryRegProdBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = products,
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
