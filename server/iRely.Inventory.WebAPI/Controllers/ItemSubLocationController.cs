using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Threading.Tasks;

namespace iRely.Inventory.WebApi
{
    public class ItemSubLocationController : BaseApiController<tblICItemSubLocation>
    {
        private IItemSubLocationBl _bl;

        public ItemSubLocationController(IItemSubLocationBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("SearchItemSubLocations")]
        public async Task<HttpResponseMessage> SearchItemSubLocations(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemSubLocations(param));
        }
    }
}
