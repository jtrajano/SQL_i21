using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using System.Diagnostics;
using System.Threading.Tasks;
using System.Threading;
using System.Web;
using System.IO;

using iRely.Inventory.BusinessLayer;
using Newtonsoft.Json;
using iRely.Inventory.Model;
using iRely.Common;
using System.Data.Entity;

namespace iRely.Inventory.WebApi.Controllers
{
    public class ImportDataController : ApiController
    {
        private ImportData bl;

        public ImportDataController()
        {
            bl = new ImportData();
        }

        [HttpPost]
        [ActionName("Import")]
        public async Task<HttpResponseMessage> Import()
        {
            return await ImportCsv(bl.Import);
        }

        [HttpPost]
        [ActionName("ImportOrigins")]
        public async Task<HttpResponseMessage> ImportOrigins()
        {
            var type = Request.Headers.GetValues("X-Import-Type").First();
            GlobalSettings.Instance.FileType = "SQL query";
            GlobalSettings.Instance.FileName = "Origin";
            GlobalSettings.Instance.ImportType = type;
            GlobalSettings.Instance.LineOfBusiness = Request.Headers.GetValues("X-Import-LineOfBusiness").First();
            ImportDataResult output = await bl.ImportOrigins(type);
            return Request.CreateResponse(HttpStatusCode.OK, output);
        }

        private async Task<HttpResponseMessage> ImportCsv(Func<byte[], string, Task<ImportDataResult>> func)
        {
            try
            {
                var data = await Request.Content.ReadAsByteArrayAsync();
                var type = Request.Headers.GetValues("X-Import-Type").First();
                var fileType = Request.Headers.GetValues("X-File-Type").First();
                GlobalSettings.Instance.FileType = fileType;
                GlobalSettings.Instance.AllowOverwriteOnImport = bool.Parse(Request.Headers.GetValues("X-Import-Allow-Overwrite").First());
                GlobalSettings.Instance.AllowDuplicates = bool.Parse(Request.Headers.GetValues("X-Import-Allow-Duplicates").First());
                GlobalSettings.Instance.VerboseLog = bool.Parse(Request.Headers.GetValues("X-Import-Enable-Verbose-Logging").First());
                GlobalSettings.Instance.ImportType = type;
                GlobalSettings.Instance.FileName = Request.Headers.GetValues("X-File-Name").First();

                var output = await func(data, type);
                return Request.CreateResponse(HttpStatusCode.OK, output);
            }
            catch (Exception ex)
            {
                var ImportResult = new ImportDataResult();
                ImportResult.Username = iRely.Common.Security.GetUserName();
                ImportResult.AddWarning(new ImportDataMessage()
                {
                    Type = Constants.TYPE_EXCEPTION,
                    Value = "Save Logs",
                    Action = "Import might be successful but logs were not written to database.",
                    Column = "",
                    Exception = ex,
                    Row = 1,
                    Status = Constants.STAT_FAILED,
                    Message = ex.Message
                });
                ImportResult.Failed = true;
                ImportResult.Type = Constants.TYPE_EXCEPTION;
                ImportResult.Description = ex.Message + (ex.InnerException != null ? " -> " + (ex.InnerException.InnerException != null ? ex.InnerException.InnerException.Message : ex.InnerException.Message) : "");
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ImportResult);
            }
        }
    }
}