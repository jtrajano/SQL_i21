using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Threading.Tasks;

namespace iRely.Inventory.WebApi
{
    public class LotController : BaseApiController<tblICLot>
    {
        private ILotBl _bl;

        public LotController(ILotBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetLots(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetLots(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetHistory(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetHistory(param));
        }
    }
}
