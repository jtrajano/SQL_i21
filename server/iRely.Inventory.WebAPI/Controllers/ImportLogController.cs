using iRely.Common;
using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;
using System;
using System.Net;

namespace iRely.Inventory.WebApi
{
    public class ImportLogController : BaseApiController<tblICImportLog>
    {
        private IImportLogBl _bl;

        public ImportLogController(IImportLogBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("searchimportlogs")]
        public async Task<HttpResponseMessage> SearchImportLogs(GetParameter param)
        {
            try
            {
                return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchImportLogs(param));
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, new { message = ex.Message, exception = ex });
            }
        }
    }
}
