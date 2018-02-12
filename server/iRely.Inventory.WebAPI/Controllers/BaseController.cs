using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http.ModelBinding;

namespace iRely.Inventory.WebApi
{
    public class BaseController<TEntity> : BaseApiController<TEntity>
        where TEntity : BaseEntity
    {
        public BaseController(IBusinessLayer<TEntity> bl) : base(bl)
        {
        }

        public override async Task<HttpResponseMessage> Get([ModelBinder] GetParameter param)
        {
            if(!ModelState.IsValid)
            {
                var errorList = GetErrorListFromModelState(ModelState);
                return await Task.FromResult(Request.CreateResponse(HttpStatusCode.BadRequest, errorList));
            }
            return await base.Get(param);
        }

        public List<string> GetErrorListFromModelState(ModelStateDictionary modelState)
        {
            var query = from state in modelState.Values
                        from error in state.Errors
                        select error.ErrorMessage;

            var errorList = query.ToList();
            return errorList;
        }
    }
}