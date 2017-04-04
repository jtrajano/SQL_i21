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
    public class ItemFactoryController : BaseApiController<tblICItemFactory>
    {
        private IItemFactoryBl _bl;

        public ItemFactoryController(IItemFactoryBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("SearchItemFactoryManufacturingCells")]
        public async Task<HttpResponseMessage> SearchItemFactoryManufacturingCells(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemFactoryManufacturingCells(param));
        }

    }

    public class ItemOwnerController : BaseApiController<tblICItemOwner>
    {
        private IItemOwnerBl _bl;

        public ItemOwnerController(IItemOwnerBl bl)
            : base(bl)
        {
            _bl = bl;
        }
        
    }
}
