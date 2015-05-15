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
    public class ItemPricingController : BaseApiController<tblICItemPricing>
    {
        private IItemPricingBl _bl;

        public ItemPricingController(IItemPricingBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemPricingViews(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemPricingViews(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemPricingLevels(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemPricingLevels(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemSpecialPricings(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemSpecialPricings(param));
        }

    }

}
