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
    public class ItemSubstituteController : BaseApiController<tblICItemSubstitute>
    {
        private IItemSubstituteBl _bl;

        public ItemSubstituteController(IItemSubstituteBl bl)
            : base(bl)
        {
            _bl = bl;
        }


        [HttpGet]
        public async Task<HttpResponseMessage> GetItemSubstitutes(int intItemId, int intItemUOMId, int intLocationId, decimal? dblQuantity)
        {
            var result = await _bl.GetItemSubstitutes(intItemId, intItemUOMId, intLocationId, dblQuantity);
            return Request.CreateResponse(HttpStatusCode.OK, result);
        }
    }
}
