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
        public async Task<HttpResponseMessage> SearchPackedUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchPackedUOMs(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetAreaLengthUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAreaLengthUOM(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetQuantityVolumeWeightPackedAreaUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetQuantityVolumeWeightPackedAreaUOM(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetTimeUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetTimeUOM(param));
        }
    }
}
