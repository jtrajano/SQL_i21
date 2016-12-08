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
    }
}
