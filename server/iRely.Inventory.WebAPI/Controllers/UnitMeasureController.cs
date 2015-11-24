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
    public class UnitMeasureController : BaseApiController<tblICUnitMeasure>
    {
        private IUnitMeasureBl _bl;

        public UnitMeasureController(IUnitMeasureBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetPackedUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetPackedUOMs(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetAreaLengthUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAreaLengthUOM(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetQuantityVolumeWeightPackedUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetQuantityVolumeWeightPackedUOM(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetTimeUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetTimeUOM(param));
        }
    }
}
