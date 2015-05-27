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
    public class ItemVendorXrefController : BaseApiController<tblICItemVendorXref>
    {
        private IItemVendorXrefBl _bl;

        public ItemVendorXrefController(IItemVendorXrefBl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }

    public class ItemCustomerXrefController : BaseApiController<tblICItemCustomerXref>
    {
        private IItemCustomerXrefBl _bl;

        public ItemCustomerXrefController(IItemCustomerXrefBl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }
}
