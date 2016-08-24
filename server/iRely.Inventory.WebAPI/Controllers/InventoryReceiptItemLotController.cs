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
    public class InventoryReceiptItemLotController : BaseApiController<tblICInventoryReceiptItemLot>
    {
        private IInventoryReceiptItemLotBl bl;

        public InventoryReceiptItemLotController(IInventoryReceiptItemLotBl bl)
            : base(bl)
        {
            this.bl = bl;
        }

        [HttpGet]
        [ActionName("GetLots")]
        public async Task<HttpResponseMessage> GetLots(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await bl.GetLots(param));
        }
    }
}