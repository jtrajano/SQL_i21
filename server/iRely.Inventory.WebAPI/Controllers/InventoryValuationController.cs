using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Threading.Tasks;
using System.Web.Http;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace iRely.Inventory.WebApi.Controllers
{
    public class InventoryValuation
    {
        public DateTime? dtmStartDate { get; set; }
        public string strItemNo { get; set; }
        public bool isPeriodic { get; set; }
    }

    public class InventoryValuationController : ApiController
    {
        [HttpPost]        
        [ActionName("RepostInventory")]
        public async Task<HttpResponseMessage> RepostInventory([FromBody]InventoryValuation parameters)
        {
            var db = new InventoryEntities();
            var success = false;
            var msg = "An unknown error occurred.";
            try
            {
                var dtmStartDate = parameters.dtmStartDate;
                var strItemNo = parameters.strItemNo;
                var isPeriodic = parameters.isPeriodic;
                await db.RepostInventory(dtmStartDate, strItemNo, isPeriodic, false);
                success = true;
                msg = "Inventory reposted successfully.";
            }
            catch (Exception ex)
            {
                msg = "Error reposting inventory. " + ex.Message;
            }

            var response = new
            {
                success = success,
                message = msg
            };

            return Request.CreateResponse(response.success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, response);
        }

        class FiscalPeriod
        {
            public string strFiscalYear { get; set; }
            public string strPeriod { get; set; }
            public DateTime? dtmStartDate { get; set; }
            public DateTime? dtmEndDate { get; set; }
            public bool? ysnOpen { get; set; }
            public bool? ysnINVOpen { get; set; }
            public bool? ysnStatus { get; set; }
            public int intFiscalYearId { get; set; }
            public int intGLFiscalYearPeriodId { get; set; }
            public int? intStartMonth { get; set; }
            public string strStartMonth { get; set; }
            public int? intEndMonth { get; set; }
            public string strEndMonth { get; set; }
        }

        [HttpGet]
        [ActionName("GetFiscalMonths")]
        public async Task<HttpResponseMessage> GetFiscalMonths()
        {
            var db = new InventoryEntities();
            var success = false;
            var data = new List<FiscalPeriod>();
            var msg = "An unknown error occurred.";
            try
            {
                var parameters = new string[0];
                var query = db.Database.SqlQuery<FiscalPeriod>(
                    @"SELECT y.strFiscalYear, f.strPeriod, f.dtmStartDate, f.dtmEndDate, f.ysnOpen, f.ysnINVOpen, y.ysnStatus, f.intFiscalYearId, f.intGLFiscalYearPeriodId,
                        DATENAME(MM, f.dtmStartDate) strStartMonth, DATEPART(MM, f.dtmStartDate) intStartMonth, DATENAME(MM, f.dtmEndDate) strEndMonth, DATEPART(MM, f.dtmEndDate) intEndMonth
                    FROM tblGLFiscalYearPeriod f
                    INNER JOIN tblGLFiscalYear y ON y.intFiscalYearId = f.intFiscalYearId
                    INNER JOIN tblGLCurrentFiscalYear c ON c.intFiscalYearId = f.intFiscalYearId"
                , parameters);
                data = await query.ToListAsync();
                success = true;
                msg = "Success.";
            }
            catch (Exception ex)
            {
                msg = "Error fetching fiscal months. " + ex.Message;
            }

            var response = new
            {
                data = data,
                success = success,
                message = msg
            };
            return Request.CreateResponse(response.success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, response);
        }
    }
}
