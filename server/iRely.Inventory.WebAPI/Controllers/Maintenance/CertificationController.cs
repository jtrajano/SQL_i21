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
    public class CertificationController : ApiController
    {
        private Certification _CertificationBRL = new Certification();

        [HttpGet]
        public HttpResponseMessage SearchCertifications(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCertification>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCertification>(searchFilters);

            var data = _CertificationBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _CertificationBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetCertifications")]
        public HttpResponseMessage GetCertifications(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICCertification>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intCertificationId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICCertification>(searchFilters, true);

            var total = _CertificationBRL.GetCount(predicate);
            var data = _CertificationBRL.GetCertifications(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostCertifications(IEnumerable<tblICCertification> certifications, bool continueOnConflict = false)
        {
            foreach (var certification in certifications)
                _CertificationBRL.AddCertification(certification);

            var result = _CertificationBRL.Save(continueOnConflict);
            _CertificationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = certifications,
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
        public HttpResponseMessage PutCertifications(IEnumerable<tblICCertification> certifications, bool continueOnConflict = false)
        {
            foreach (var certification in certifications)
                _CertificationBRL.UpdateCertification(certification);

            var result = _CertificationBRL.Save(continueOnConflict);
            _CertificationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = certifications,
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
        public HttpResponseMessage DeleteCertifications(IEnumerable<tblICCertification> certifications, bool continueOnConflict = false)
        {
            foreach (var certification in certifications)
                _CertificationBRL.DeleteCertification(certification);

            var result = _CertificationBRL.Save(continueOnConflict);
            _CertificationBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = certifications,
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
