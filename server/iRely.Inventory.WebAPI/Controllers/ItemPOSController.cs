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
    public class ItemPOSCategoryController : BaseApiController<tblICItemPOSCategory>
    {
        private IItemPOSCategoryBl _bl;

        public ItemPOSCategoryController(IItemPOSCategoryBl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }

    public class ItemPOSSLAController : BaseApiController<tblICItemPOSSLA>
    {
        private IItemPOSSLABl _bl;

        public ItemPOSSLAController(IItemPOSSLABl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }
}
