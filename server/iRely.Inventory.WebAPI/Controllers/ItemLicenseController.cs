using iRely.Common;
using iRely.Inventory.BusinessLayer;
using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;

namespace iRely.Inventory.WebApi
{
    public class ItemLicenseController : BaseApiController<tblICItemLicense>
    {
        private IItemLicenseBl _bl;
        public ItemLicenseController(IItemLicenseBl bl) : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetItemLicense")]
        public async Task<HttpResponseMessage> GetItemLicense(GetParameter param)
        {
            var result = await _bl.GetItemLicense(param);
            return Request.CreateResponse(HttpStatusCode.OK, result);
        }
    }
}
