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
using System.Data.SqlClient;

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
        [ActionName("RebuildInventory")]
        public async Task<HttpResponseMessage> RebuildInventory([FromBody]InventoryValuation parameters)
        {
            var db = new InventoryEntities();
            var success = false;
            var msg = "An unknown error occurred.";
            try
            {
                var dtmStartDate = parameters.dtmStartDate;
                var strItemNo = parameters.strItemNo;
                var isPeriodic = parameters.isPeriodic;
                await db.RebuildInventory(dtmStartDate, strItemNo, isPeriodic, false, iRely.Common.Security.GetEntityId());
                success = true;
                msg = "Inventory rebuilt successfully.";
            }
            catch (Exception ex)
            {
                msg = "Error rebuilding inventory. " + ex.Message;
            }

            var response = new
            {
                success = success,
                message = msg
            };

            return Request.CreateResponse(response.success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, response);
        }

        [HttpGet]
        [ActionName("CompareRebuiltValuationSnapshot")]
        public async Task<HttpResponseMessage> CompareRebuiltValuationSnapshot([FromUri]DateTime dtmStartDate)
        {
            var db = new InventoryEntities();
            var success = false;
            var msg = "An unknown error occurred.";
            try
            {
                await db.CompareRebuiltValuationSnapshot(dtmStartDate);
                success = true;
                msg = "No changes.";
            }
            catch (Exception ex)
            {
                msg = ex.Message;
            }

            var response = new
            {
                success = msg.Contains("Check the Rebuild Valuation GL Snapshot") ? true : success,
                message = msg
            };

            return Request.CreateResponse(response.success ? (msg.Contains("Check the Rebuild Valuation GL Snapshot") ? HttpStatusCode.Accepted : HttpStatusCode.OK) : HttpStatusCode.InternalServerError, response);
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
                        INNER JOIN tblGLCurrentFiscalYear c ON c.intFiscalYearId = f.intFiscalYearId
                        INNER JOIN tblGLFiscalYear y ON y.intFiscalYearId = f.intFiscalYearId WHERE f.ysnOpen = 1 ORDER BY dtmStartDate ASC"
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

        class Discrepancy
        {
            public int? intAccountId { get; set; }
            public string strAccountId { get; set; }
            public string strDescription { get; set; }
            public DateTime? dtmRebuildDate { get; set; }
            public string strRebuildDate { get; set; }
            public int? intYear { get; set; }
            public int? intMonth { get; set; }
            public decimal? dblDebit_Snapshot { get; set; }
            public decimal? dblCredit_Snapshot { get; set; }
            public decimal? dblDebit_ActualGLDetail { get; set; }
            public decimal? dblCredit_ActualGLDetail { get; set; }
            public decimal? DebitDiff { get; set; }
            public decimal? CreditDiff { get; set; }
        }

        [HttpGet]
        [ActionName("GetDiscrepancies")]
        public async Task<HttpResponseMessage> GetDiscrepancies(DateTime? dtmDate)
        {
            var db = new InventoryEntities();
            var success = false;
            var data = new List<Discrepancy>();
            var msg = "An unknown error occurred.";
            try
            {
                var param = new SqlParameter("@dtmDate", dtmDate);
                param.Value = dtmDate;
                param.DbType = System.Data.DbType.DateTime;
                var query = db.Database.SqlQuery<Discrepancy>(
                    @"SELECT intAccountId, strAccountId, strDescription, CONVERT(VARCHAR(50), dtmRebuildDate, 1) strRebuildDate, dtmRebuildDate, intYear, intMonth, dblDebit_Snapshot, 
                        dblCredit_Snapshot, dblDebit_ActualGLDetail, dblCredit_ActualGLDetail, [Debit Diff] AS DebitDiff, [Credit Diff] AS CreditDiff 
                    FROM vyuICCompareRebuildValuationSnapshot
                    WHERE CAST(CONVERT(VARCHAR(50), dtmRebuildDate, 1)AS DATETIME) >= @dtmDate"
                , param);
                data = await query.ToListAsync();
                success = true;
                msg = "Success.";
            }
            catch (Exception ex)
            {
                msg = "Error fetching discrepancies. " + ex.Message;
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
