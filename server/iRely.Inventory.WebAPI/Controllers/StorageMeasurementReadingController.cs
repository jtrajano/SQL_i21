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
using System.Data.Entity;

namespace iRely.Inventory.WebApi
{
    public class StorageMeasurementReadingController : BaseApiController<tblICStorageMeasurementReading>
    {
        private IStorageMeasurementReadingBl _bl;

        public StorageMeasurementReadingController(IStorageMeasurementReadingBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("SearchStorageMeasurementReadingConversion")]
        public async Task<HttpResponseMessage> SearchStorageMeasurementReadingConversion(GetParameter param)
        {
            var result = new SearchResult();
            var query = ((StorageMeasurementReadingBl)_bl).GetRepository().GetQuery<vyuICGetStorageMeasurementReadingConversion>()
                    .Filter(param, true);
            try
            {
                var data = await query.Execute(param, "intStorageMeasurementReadingConversionId").ToListAsync();

                result = new SearchResult()
                {
                    data = data.AsQueryable(),
                    success = true,
                    total = await query.CountAsync()
                };
            }
            catch (Exception ex)
            {
                result = new SearchResult()
                {
                    success = false,
                    summaryData = ex.InnerException != null ? ex.InnerException.Message : ex.Message
                };
            }

            return Request.CreateResponse(result.success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
        }
    }
}
