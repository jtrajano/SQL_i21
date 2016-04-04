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
        [ActionName("GetItemLocationViews")]
        public async Task<HttpResponseMessage> GetItemLocationViews(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemLocationViews(param));
        }

        [HttpPost]
        [ActionName("CheckCostingMethod")]
        public HttpResponseMessage CheckCostingMethod(int ItemId, int ItemLocationId, int CostingMethod)
        {
            var result = _bl.CheckCostingMethod(ItemId, ItemLocationId, CostingMethod);

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
