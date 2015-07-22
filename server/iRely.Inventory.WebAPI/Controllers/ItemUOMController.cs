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
    public class ItemUOMController : BaseApiController<tblICItemUOM>
    {
        private IItemUOMBl _bl;

        public ItemUOMController(IItemUOMBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetWeightUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetWeightUOMs(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetWeightVolumeUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetWeightVolumeUOMs(param));
        }

    }
}
