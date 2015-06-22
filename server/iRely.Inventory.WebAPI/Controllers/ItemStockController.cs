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
    public class ItemStockController : BaseApiController<tblICItemStock>
    {
        private IItemStockBl _bl;

        public ItemStockController(IItemStockBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemStockUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockUOMView(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemStockUOMForAdjustment(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockUOMForAdjustmentView(param));
        }
    }
}
