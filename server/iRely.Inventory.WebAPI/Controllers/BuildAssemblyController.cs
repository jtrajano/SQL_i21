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
    public class BuildAssemblyController : BaseApiController<tblICBuildAssembly>
    {
        private IBuildAssemblyBl _bl;

        public BuildAssemblyController(IBuildAssemblyBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpPost]
        public HttpResponseMessage PostTransaction(BusinessLayer.Common.Posting_RequestModel assembly)
        {
            var result = _bl.PostTransaction(assembly, assembly.isRecap);

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
