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
    public class InventoryReceiptChargeTaxController : BaseApiController<tblICInventoryReceiptChargeTax>
    {
        private IInventoryReceiptChargeTaxBl _bl;

        public InventoryReceiptChargeTaxController(IInventoryReceiptChargeTaxBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetReceiptChargeTaxView")]
        public async Task<HttpResponseMessage> GetReceiptChargeTaxView(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetReceiptChargeTaxView(param));
        }
    }
}
