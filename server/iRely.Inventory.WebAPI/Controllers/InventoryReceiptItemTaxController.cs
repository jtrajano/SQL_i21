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
    public class InventoryReceiptItemTaxController : BaseController<tblICInventoryReceiptItemTax>
    {
        private IInventoryReceiptItemTaxBl _bl;

        public InventoryReceiptItemTaxController(IInventoryReceiptItemTaxBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetReceiptItemTaxView")]
        public async Task<HttpResponseMessage> GetReceiptItemTaxView(GetParameter param, int ReceiptItemId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetReceiptItemTaxView(param, ReceiptItemId));
        }
    }
}
