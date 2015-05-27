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
        public async Task<HttpResponseMessage> GetClassAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetClassAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetGradeAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetGradeAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetOriginAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetOriginAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetProductLineAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetProductLineAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetProductTypeAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetProductTypeAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetRegionAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetRegionAttributes(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetSeasonAttributes(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetSeasonAttributes(param));
        }

        

    }
}
