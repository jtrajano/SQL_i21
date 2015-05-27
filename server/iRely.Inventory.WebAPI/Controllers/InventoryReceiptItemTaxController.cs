using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;

namespace iRely.Inventory.WebApi
{
    public class InventoryReceiptItemTaxController : BaseApiController<tblICInventoryReceiptItemTax>
    {
        private IInventoryReceiptItemTaxBl _bl;

        public InventoryReceiptItemTaxController(IInventoryReceiptItemTaxBl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }
}
