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
    public class InventoryShipmentItemLotController : BaseApiController<tblICInventoryShipmentItemLot>
    {
        private IInventoryShipmentItemLotBl _bl;

        public InventoryShipmentItemLotController(IInventoryShipmentItemLotBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("SearchShipmentLots")]
        public async Task<HttpResponseMessage> SearchShipmentLots(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchLots(param));
        }

        [HttpGet]
        [ActionName("GetShipmentLots")]
        public async Task<HttpResponseMessage> GetShipmentLots(int? intInventoryShipmentItemId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetLots(intInventoryShipmentItemId));
        }
    }
}