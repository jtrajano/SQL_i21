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
    public class QAPropertyController : ApiController
    {
         private QAProperty _QAPropertyBRL = new QAProperty();

        [HttpGet]
        public HttpResponseMessage SearchQAProperties(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblMFQAProperty>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblMFQAProperty>(searchFilters);

            var data = _QAPropertyBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _QAPropertyBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetQAProperties")]
        public HttpResponseMessage GetQAProperties(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblMFQAProperty>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intQAPropertyId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblMFQAProperty>(searchFilters, true);

            var total = _QAPropertyBRL.GetCount(predicate);
            var data = _QAPropertyBRL.GetQAProperties(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostQAProperties(IEnumerable<tblMFQAProperty> properties, bool continueOnConflict = false)
        {
            foreach (var property in properties)
                _QAPropertyBRL.AddQAProperty(property);

            var result = _QAPropertyBRL.Save(continueOnConflict);
            _QAPropertyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = properties,
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
        public HttpResponseMessage PutQAProperties(IEnumerable<tblMFQAProperty> properties, bool continueOnConflict = false)
        {
            foreach (var property in properties)
                _QAPropertyBRL.UpdateQAProperty(property);

            var result = _QAPropertyBRL.Save(continueOnConflict);
            _QAPropertyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = properties,
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
        public HttpResponseMessage DeleteQAProperties(IEnumerable<tblMFQAProperty> properties, bool continueOnConflict = false)
        {
            foreach (var property in properties)
                _QAPropertyBRL.DeleteQAProperty(property);

            var result = _QAPropertyBRL.Save(continueOnConflict);
            _QAPropertyBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = properties,
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
