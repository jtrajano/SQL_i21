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
        [ActionName("SearchCompactItems")]
        public async Task<HttpResponseMessage> SearchCompactItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchCompactItems(param));
        }

        [HttpGet]
        [ActionName("SearchAssemblyComponents")]
        public async Task<HttpResponseMessage> SearchAssemblyComponents(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchAssemblyComponents(param));
        }

        [HttpGet]
        [ActionName("SearchBundleComponents")]
        public async Task<HttpResponseMessage> SearchBundleComponents(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchBundleComponents(param));
        }

        [HttpGet]
        [ActionName("SearchItemStocks")]
        public async Task<HttpResponseMessage> SearchItemStocks(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStocks(param));
        }

        [HttpGet]
        [ActionName("SearchItemStockDetails")]
        public async Task<HttpResponseMessage> SearchItemStockDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemStockDetails(param));
        }

        [HttpGet]
        [ActionName("GetItemStockUOMSummary")]
        public async Task<HttpResponseMessage> GetItemStockUOMSummary(int? ItemId, int? LocationId, int? SubLocationId, int? StorageLocationId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockUOMSummary(ItemId, LocationId, SubLocationId, StorageLocationId));
        }

        [HttpGet]
        [ActionName("SearchAssemblyItems")]
        public async Task<HttpResponseMessage> SearchAssemblyItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchAssemblyItems(param));
        }

        [HttpGet]
        [ActionName("SearchItemUPCs")]
        public async Task<HttpResponseMessage> SearchItemUPCs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemUPCs(param));
        }

        [HttpGet]
        [ActionName("SearchInventoryValuation")]
        public async Task<HttpResponseMessage> SearchInventoryValuation(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchInventoryValuation(param));
        }

        [HttpGet]
        [ActionName("SearchInventoryValuationSummary")]
        public async Task<HttpResponseMessage> SearchInventoryValuationSummary(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchInventoryValuationSummary(param));
        }

        [HttpGet]
        [ActionName("SearchOtherCharges")]
        public async Task<HttpResponseMessage> SearchOtherCharges(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchOtherCharges(param));
        }

        [HttpGet]
        [ActionName("SearchItemCommodities")]
        public async Task<HttpResponseMessage> SearchItemCommodities(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemCommodities(param));
        }

        [HttpGet]
        [ActionName("SearchStockTrackingItems")]
        public async Task<HttpResponseMessage> SearchStockTrackingItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchStockTrackingItems(param));
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
            var result = _bl.DuplicateItem(ItemId) as ItemBl.DuplicateItemSaveResult;

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    id = result.Id,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        public struct ItemParam
        {
            public int ItemId { get; set; }
            public bool ItemStockUnit { get; set; }
            public int ItemUOMId { get; set; }
        }

        [HttpPost]
        [ActionName("CheckStockUnit")]
        public HttpResponseMessage CheckStockUnit(ItemParam param)
        {
            var result = _bl.CheckStockUnit(param.ItemId, param.ItemStockUnit, param.ItemUOMId);

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

        public struct CopyItemLocationParam
        {
            public int intSourceItemId { get; set; }
            public string strDestinationItemIds { get; set; }
        }

        [HttpPost]
        [ActionName("CopyItemLocation")]
        public HttpResponseMessage CopyItemLocation(CopyItemLocationParam param)
        {
            var result = _bl.CopyItemLocation(param.intSourceItemId, param.strDestinationItemIds);

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
        public HttpResponseMessage ConvertItemToNewStockUnit(ItemParam param)
        {
            var result = _bl.ConvertItemToNewStockUnit(param.ItemId, param.ItemUOMId);

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

        [HttpGet]
        [ActionName("SearchItemOwner")]
        public async Task<HttpResponseMessage> SearchItemOwner(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemOwner(param));
        }

        [HttpGet]
        [ActionName("SearchItemSubLocations")]
        public async Task<HttpResponseMessage> SearchItemSubLocations(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemSubLocations(param));
        }

        [HttpGet]
        [ActionName("GetItemMotorFuelTax")]
        public async Task<HttpResponseMessage> GetItemMotorFuelTax(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemMotorFuelTax(param));
        }

    }
}
