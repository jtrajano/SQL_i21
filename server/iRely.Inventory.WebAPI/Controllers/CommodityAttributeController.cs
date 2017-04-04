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
    public class CommodityAttributeController : BaseApiController<tblICCommodityAttribute>
    {
        private ICommodityAttributeBl _bl;

        public CommodityAttributeController(ICommodityAttributeBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchClassAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchClassAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchGradeAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchGradeAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchOriginAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchOriginAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchProductLineAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchProductLineAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchProductTypeAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchProductTypeAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchRegionAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchRegionAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchSeasonAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchSeasonAttributes(param));
        }

        

    }
}
