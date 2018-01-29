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
    public class InventoryShipmentChargeTaxController : BaseApiController<tblICInventoryShipmentChargeTax>
    {
        private IInventoryShipmentChargeTaxBl _bl;

        public InventoryShipmentChargeTaxController(IInventoryShipmentChargeTaxBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetShipmentChargeTaxView")]
        public async Task<HttpResponseMessage> GetShipmentChargeTaxView(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetShipmentChargeTaxView(param));
        }
    }
}
