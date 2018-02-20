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
    public class ItemAddOnController : BaseApiController<tblICItemAddOn>
    {
        private IItemAddOnBl _bl;

        public ItemAddOnController(IItemAddOnBl bl)
            : base(bl)
        {
            _bl = bl;
        }


        [HttpGet]
        public async Task<HttpResponseMessage> GetItemAddOns(int intItemId, int intItemUOMId, int intLocationId, decimal? dblQuantity)
        {
            var result = await _bl.GetItemAddOns(intItemId, intItemUOMId, intLocationId, dblQuantity);
            return Request.CreateResponse(HttpStatusCode.OK, result);
        }
    }
}
