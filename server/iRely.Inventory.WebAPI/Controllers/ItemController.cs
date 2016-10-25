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
    public class ItemController : BaseApiController<tblICItem>
    {
        private IItemBl _bl;

        public ItemController(IItemBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetCompactItems")]
        public async Task<HttpResponseMessage> GetCompactItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetCompactItems(param));
        }

        [HttpGet]
        [ActionName("GetAssemblyComponents")]
        public async Task<HttpResponseMessage> GetAssemblyComponents(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAssemblyComponents(param));
        }

        [HttpGet]
        [ActionName("GetBundleComponents")]
        public async Task<HttpResponseMessage> GetBundleComponents(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetBundleComponents(param));
        }

        [HttpGet]
        [ActionName("GetItemStocks")]
        public async Task<HttpResponseMessage> GetItemStocks(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStocks(param));
        }

        [HttpGet]
        [ActionName("GetItemStockDetails")]
        public async Task<HttpResponseMessage> GetItemStockDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockDetails(param));
        }

        [HttpGet]
        [ActionName("GetItemStockUOMSummary")]
        public async Task<HttpResponseMessage> GetItemStockUOMSummary(int? ItemId, int? LocationId, int? SubLocationId, int? StorageLocationId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockUOMSummary(ItemId, LocationId, SubLocationId, StorageLocationId));
        }

        [HttpGet]
        [ActionName("GetAssemblyItems")]
        public async Task<HttpResponseMessage> GetAssemblyItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAssemblyItems(param));
        }

        [HttpGet]
        [ActionName("GetItemUPCs")]
        public async Task<HttpResponseMessage> GetItemUPCs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemUPCs(param));
        }

        [HttpGet]
        [ActionName("GetInventoryValuation")]
        public async Task<HttpResponseMessage> GetInventoryValuation(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetInventoryValuation(param));
        }

        [HttpGet]
        [ActionName("GetInventoryValuationSummary")]
        public async Task<HttpResponseMessage> GetInventoryValuationSummary(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetInventoryValuationSummary(param));
        }

        [HttpGet]
        [ActionName("GetOtherCharges")]
        public async Task<HttpResponseMessage> GetOtherCharges(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetOtherCharges(param));
        }

        [HttpGet]
        [ActionName("GetItemCommodities")]
        public async Task<HttpResponseMessage> GetItemCommodities(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemCommodities(param));
        }

        [HttpGet]
        [ActionName("GetStockTrackingItems")]
        public async Task<HttpResponseMessage> GetStockTrackingItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetStockTrackingItems(param));
        }

        [HttpGet]
        [ActionName("GetItemUOMsByType")]
        public async Task<HttpResponseMessage> GetItemUOMsByType(int? intItemId = 0, string strUnitType = "")
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemUOMsByType(intItemId, strUnitType));
        }

        [HttpGet]
        [ActionName("DuplicateItem")]
        public HttpResponseMessage DuplicateItem(int ItemId)
        {
            var NewItemId = _bl.DuplicateItem(ItemId);
            return Request.CreateResponse(HttpStatusCode.OK, new
            {
                id = NewItemId
            });
        }

        [HttpPost]
        [ActionName("CheckStockUnit")]
        public HttpResponseMessage CheckStockUnit(int ItemId, bool ItemStockUnit, int ItemUOMId)
        {
            var result = _bl.CheckStockUnit(ItemId, ItemStockUnit, ItemUOMId);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }


        [HttpPost]
        [ActionName("ConvertItemToNewStockUnit")]
        public HttpResponseMessage ConvertItemToNewStockUnit(int ItemId, int ItemUOMId)
        {
            var result = _bl.ConvertItemToNewStockUnit(ItemId, ItemUOMId);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
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
