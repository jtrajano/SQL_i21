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
        [ActionName("GetItemPricingViews")]
        public async Task<HttpResponseMessage> GetItemPricingViews(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemPricingViews(param));
        }

        [HttpGet]
        [ActionName("GetItemStockPricingViews")]
        public async Task<HttpResponseMessage> GetItemStockPricingViews(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockPricingViews(param));
        }
    }

    public class ItemPricingLevelController : BaseApiController<tblICItemPricingLevel>
    {
        private IItemPricingLevelBl _bl;

        public ItemPricingLevelController(IItemPricingLevelBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetItemPricingLevel")]
        public async Task<HttpResponseMessage> GetItemPricingLevel(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemPricingLevel(param));
        }
    }

    public class ItemSpecialPricingController : BaseApiController<tblICItemSpecialPricing>
    {
        private IItemSpecialPricingBl _bl;

        public ItemSpecialPricingController(IItemSpecialPricingBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetItemSpecialPricing")]
        public async Task<HttpResponseMessage> GetItemSpecialPricing(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemSpecialPricing(param));
        }
    }

}
