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
    public class ItemNoteController : ApiController
    {
        private ItemNote _ItemNoteBRL = new ItemNote();

        [HttpGet]
        public HttpResponseMessage SearchItemNotes(int page, int start, int limit, string columns = "", string sort = "", string filter = "")
        {
            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemNote>();
            var selector = ExpressionBuilder.GetSelector(columns);

            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts);

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemNote>(searchFilters);

            var data = _ItemNoteBRL.GetSearchQuery(page, start, limit, selector, sortSelector, predicate);

            var total = _ItemNoteBRL.GetCount(predicate);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data,
                total = total
            });
        }

        [HttpGet]
        [ActionName("GetItemNotes")]
        public HttpResponseMessage GetItemNotes(int start = 0, int limit = 1, int page = 0, string sort = "", string filter = "")
        {
            filter = string.IsNullOrEmpty(filter) ? "" : filter;

            var searchFilters = JsonConvert.DeserializeObject<IEnumerable<SearchFilter>>(filter);
            var searchSorts = JsonConvert.DeserializeObject<IEnumerable<SearchSort>>(sort);
            var predicate = ExpressionBuilder.True<tblICItemNote>();
            var sortSelector = ExpressionBuilder.GetSortSelector(searchSorts, "intItemNoteId", "DESC");

            if (searchFilters != null)
                predicate = ExpressionBuilder.GetPredicateBasedOnSearch<tblICItemNote>(searchFilters, true);

            var total = _ItemNoteBRL.GetCount(predicate);
            var data = _ItemNoteBRL.GetItemNotes(page, start, page == 0 ? total : limit, sortSelector, predicate);

            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                data = data.ToList(),
                total = total
            });
        }

        [HttpPost]
        public HttpResponseMessage PostItemNotes(IEnumerable<tblICItemNote> notes, bool continueOnConflict = false)
        {
            foreach (var note in notes)
                _ItemNoteBRL.AddItemNote(note);

            var result = _ItemNoteBRL.Save(continueOnConflict);
            _ItemNoteBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = notes,
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
        public HttpResponseMessage PutItemNotes(IEnumerable<tblICItemNote> notes, bool continueOnConflict = false)
        {
            foreach (var note in notes)
                _ItemNoteBRL.UpdateItemNote(note);

            var result = _ItemNoteBRL.Save(continueOnConflict);
            _ItemNoteBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = notes,
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
        public HttpResponseMessage DeleteItemNotes(IEnumerable<tblICItemNote> notes, bool continueOnConflict = false)
        {
            foreach (var note in notes)
                _ItemNoteBRL.DeleteItemNote(note);

            var result = _ItemNoteBRL.Save(continueOnConflict);
            _ItemNoteBRL.Dispose();

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = notes,
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
