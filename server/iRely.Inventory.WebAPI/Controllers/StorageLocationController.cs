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
        [ActionName("SearchStorageBins")]
        public async Task<HttpResponseMessage> SearchStorageBins(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchStorageBins(param));
        }

        [HttpGet]
        [ActionName("SearchSubLocationBins")]
        public async Task<HttpResponseMessage> SearchSubLocationBins(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchSubLocationBins(param));
        }

        [HttpGet]
        [ActionName("SearchSubLocationBinDetails")]
        public async Task<HttpResponseMessage> SearchSubLocationBinDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchSubLocationBinDetails(param));
        }

        [HttpGet]
        [ActionName("SearchStorageBinDetails")]
        public async Task<HttpResponseMessage> SearchStorageBinDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchStorageBinDetails(param));
        }

        [HttpGet]
        [ActionName("GetStorageBinMeasurementReading")]
        public async Task<HttpResponseMessage> GetStorageBinMeasurementReading(GetParameter param, int intStorageLocationId)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetStorageBinMeasurementReading(param, intStorageLocationId));
        }

        [HttpGet]
        [ActionName("DuplicateStorageLocation")]
        public HttpResponseMessage DuplicateStorageLocation(int StorageLocationId)
        {
            var result = _bl.DuplicateStorageLocation(StorageLocationId) as StorageLocationBl.DuplicateStorageLocationSaveResult;

            var httpStatusCode = HttpStatusCode.OK;
            if (result.HasError) httpStatusCode = HttpStatusCode.BadRequest;

            return Request.CreateResponse(httpStatusCode, new
            {
                success = !result.HasError,
                message = new
                {
                    id = result.Id,
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }
    }
}
