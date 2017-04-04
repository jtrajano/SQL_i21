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
    public class ItemLocationController : BaseApiController<tblICItemLocation>
    {
        private IItemLocationBl _bl;

        public ItemLocationController(IItemLocationBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("SearchItemLocationViews")]
        public async Task<HttpResponseMessage> SearchItemLocationViews(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchItemLocationViews(param));
        }

        public struct ItemLocationParam
        {
            public int ItemId { get; set; }
            public int ItemLocationId { get; set; }
            public int CostingMethod { get; set; }
        }

        [HttpPost]
        [ActionName("CheckCostingMethod")]
        public HttpResponseMessage CheckCostingMethod(ItemLocationParam param)
        {
            var result = _bl.CheckCostingMethod(param.ItemId, param.ItemLocationId, param.CostingMethod);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                success = !result.HasError,
                message = new
                {
                    //statusText = result.Exception.Message,
                    statusText = "Costing Method cannot be changed due to Stock already Exists.",
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }
    }
}
