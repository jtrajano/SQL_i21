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
        public async Task<HttpResponseMessage> SearchWeightUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchWeightUOMs(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchWeightVolumeUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchWeightVolumeUOMs(param));
        }

        [HttpGet]
        public async Task<HttpResponseMessage> SearchUOMs(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.SearchUOMs(param));
        }
    }
}
