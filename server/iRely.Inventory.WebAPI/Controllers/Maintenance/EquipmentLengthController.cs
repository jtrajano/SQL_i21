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
    public class EquipmentLengthController : ApiController
    {
         private EquipmentLength _EquipmentLengthBRL = new EquipmentLength();

        [HttpGet]
        public HttpResponseMessage SearchEquipmentLengths(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICEquipmentLength>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICEquipmentLength>(searchFilters);

            var data = _EquipmentLengthBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _EquipmentLengthBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetEquipmentLengths")]
        public HttpResponseMessage GetEquipmentLengths(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICEquipmentLength>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intEquipmentLengthId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICEquipmentLength>(searchFilters, true);

            var total = _EquipmentLengthBRL.GetCount(predicate);
            var data = _EquipmentLengthBRL.GetEquipmentLengths(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostEquipmentLengths(IEnumerable<tblICEquipmentLength> lengths, bool continueOnConflict = false)
        {
            foreach (var length in lengths)
                _EquipmentLengthBRL.AddEquipmentLength(length);

            var result = _EquipmentLengthBRL.Save(continueOnConflict);
            _EquipmentLengthBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lengths,
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
        public HttpResponseMessage PutEquipmentLengths(IEnumerable<tblICEquipmentLength> lengths, bool continueOnConflict = false)
        {
            foreach (var length in lengths)
                _EquipmentLengthBRL.UpdateEquipmentLength(length);

            var result = _EquipmentLengthBRL.Save(continueOnConflict);
            _EquipmentLengthBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lengths,
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
        public HttpResponseMessage DeleteEquipmentLengths(IEnumerable<tblICEquipmentLength> lengths, bool continueOnConflict = false)
        {
            foreach (var length in lengths)
                _EquipmentLengthBRL.DeleteEquipmentLength(length);

            var result = _EquipmentLengthBRL.Save(continueOnConflict);
            _EquipmentLengthBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = lengths,
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
