using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Threading.Tasks;

namespace iRely.Inventory.WebApi
{
    public class StorageLocationController : BaseApiController<tblICStorageLocation>
    {
        private IStorageLocationBl _bl;

        public StorageLocationController(IStorageLocationBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetStorageBins")]
        public async Task<HttpResponseMessage> GetStorageBins(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetStorageBins(param));
        }

        [HttpGet]
        [ActionName("GetStorageBinDetails")]
        public async Task<HttpResponseMessage> GetStorageBinDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetStorageBinDetails(param));
        }

        [HttpGet]
        [ActionName("GetStorageBinMeasurementReading")]
        public async Task<HttpResponseMessage> GetStorageBinMeasurementReading(GetParameter param, int intStorageLocationId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetStorageBinMeasurementReading(param, intStorageLocationId));
        }
    }
}
