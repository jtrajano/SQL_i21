using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;


namespace iRely.Inventory.WebApi
{
    public class InventoryAdjustmentController : BaseApiController<tblICInventoryAdjustment>
    {
        private IInventoryAdjustmentBl _bl;

        public InventoryAdjustmentController(IInventoryAdjustmentBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpPost]
        public HttpResponseMessage PostTransaction(BusinessLayer.Common.Posting_RequestModel adjustment)
        {
            var result = _bl.PostTransaction(adjustment, adjustment.isRecap);
            
            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = adjustment,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

        [HttpGet]
        [ActionName("GetPostedLots")]
        public async Task<HttpResponseMessage> GetPostedLots(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetPostedLots(param));
        }

    }
}
