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
        public async Task<HttpResponseMessage> SearchItemStockUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockUOMs(param));
        }


        [HttpGet]
        public async Task<HttpResponseMessage> GetLocationStockOnHand(int? intLocationId, int? intItemId, int? intSubLocationId, int? intStorageLocationId, int? intLotId, int? intItemUOMId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetLocationStockOnHand(intLocationId, intItemId, intSubLocationId, intStorageLocationId, intLotId, intItemUOMId));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchItemStockUOMViewTotals(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockUOMViewTotals(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchItemStockUOMViewTotalsAllLocations(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockUOMViewTotalsAllLocations(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchItemStockUOMViewTotalsAllStorageUnits(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockUOMViewTotalsAllStorageUnits(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchItemStockUOMForAdjustment(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockUOMForAdjustment(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetInventoryCountItemStockLookup(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetInventoryCountItemStockLookup(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemStorageLocations(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStorageLocations(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetItemSubLocations(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemSubLocations(param));
        }
    }
}
