using iRely.Common;
using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Web.Http;
using System.Net.Http;
using System.Net;
using System;
using System.Threading.Tasks;

namespace iRely.Inventory.WebApi
{
    public class ImportLogDetailController : BaseApiController<tblICImportLogDetail>
    {
        private IImportLogDetailBl _bl;

        public ImportLogDetailController(IImportLogDetailBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("searchimportlogdetails")]
        public async Task<HttpResponseMessage> SearchImportLogDetails(GetParameter param)
        {
            try
            {
                return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchImportLogDetails(param));
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, new { message = ex.Message, exception = ex });
            }
        }
    }
}
