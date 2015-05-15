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
    public class CommodityController : BaseApiController<tblICCommodity>
    {
        private ICommodityBl _bl;

        public CommodityController(ICommodityBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetCompactCommodities(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetCompactCommodities(param));
        }
    }
}
