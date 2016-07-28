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
            ImportDataResult output = await bl.ImportOrigins(type);
            var response = new
            {
                success = output.Info == "success" ? true : false,
                info = output.Description,
                result = output
            };
            return Request.CreateResponse(response.success ? HttpStatusCode.OK : HttpStatusCode.BadRequest, response);
        }

        private async Task<HttpResponseMessage> ImportCsv(Func<byte[], string, ImportDataResult> func)
        {
            try
            {
                var data = await Request.Content.ReadAsByteArrayAsync();
                var type = Request.Headers.GetValues("X-Import-Type").First();
                GlobalSettings.Instance.AllowOverwriteOnImport = bool.Parse(Request.Headers.GetValues("X-Import-Allow-Overwrite").First());

                var output = func(data, type);
                if (output.Info == "error")
                {
                    var response = new
                    {
                        success = false,
                        info = output.Description != null ? output.Description : "Error(s) found during import.",
                        messages = output.Messages,
                        rows = output.Rows,
                        result = output
                    };
                    return Request.CreateResponse(HttpStatusCode.BadRequest, response);
                }
                else
                {
                    var response = new
                    {
                        success = true,
                        messages = output.Messages,
                        rows = output.Rows,
                        result = output
                    };
                    return Request.CreateResponse(HttpStatusCode.OK, response);
                }
            }
            catch (Exception ex)
            {
                var response = new
                {
                    success = false,
                    info = ex.Message != null ? ex.Message : "Error(s) found during import.",
                    exception = ex
                };
                return Request.CreateResponse(HttpStatusCode.BadRequest, response);
            }
        }
    }
}