using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;

namespace iRely.Inventory.WebApi
{
    public class CategoryController : BaseApiController<tblICCategory>
    {
        private ICategoryBl _bl;
        public CategoryController(ICategoryBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("DuplicateCategory")]
        public HttpResponseMessage DuplicateCategory(int intCategoryId)
        {
            var result = _bl.DuplicateCategory(intCategoryId) as CategoryBl.DuplicateCategorySaveResult;

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    id = result.Id,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }
    }
}
