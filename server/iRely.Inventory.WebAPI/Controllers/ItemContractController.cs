using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;

namespace iRely.Inventory.WebApi
{
    public class ItemContractController : BaseApiController<tblICItemContract>
    {
        private IItemContractBl _bl;

        public ItemContractController(IItemContractBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetContractItem")]
        public async Task<HttpResponseMessage> GetContractItem(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetContractItem(param));
        }

        [HttpGet]
        [ActionName("GetContractDocument")]
        public async Task<HttpResponseMessage> GetContractDocument(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetContractDocument(param));
        }
    }
}
