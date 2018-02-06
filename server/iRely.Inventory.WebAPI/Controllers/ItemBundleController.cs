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
    public class ItemBundleController : BaseApiController<tblICItemBundle>
    {
        private IItemBundleBl _bl;

        public ItemBundleController(IItemBundleBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        public async Task<HttpResponseMessage> GetBundleComponents(GetParameter param, int intBundleItemId, int intLocationId)
        {
            var result = await _bl.GetBundleComponents(param, intBundleItemId, intLocationId);
            return Request.CreateResponse(HttpStatusCode.OK, result);
        }
    }
}
