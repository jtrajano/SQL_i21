using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;
using System.Data;
using System.Data.Entity;
using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Data.SqlClient;

namespace iRely.Inventory.WebApi
{
    public class InventoryCountDetailController : BaseApiController<tblICInventoryCountDetail>
    {
        private IInventoryCountDetailBl _bl;

        public InventoryCountDetailController(IInventoryCountDetailBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpDelete]
        [ActionName("DeleteDetail")]
        public async Task<HttpResponseMessage> DeleteDetail(tblICInventoryCountDetail detail)
        {
            var bl = _bl as InventoryCountDetailBl;
            var repo = bl.GetRepository() as InventoryRepository;

            if (ModelState.IsValid && detail != null)
            {
                if (detail.intInventoryCountDetailId == 0)
                    return Request.CreateResponse(HttpStatusCode.NotFound, new { success = false, msg = "intInventoryCountDetailId or intInventoryCountId is null" });
                bl.Delete(detail);
                await bl.SaveAsync(true);
            }

            return Request.CreateResponse(HttpStatusCode.Accepted, new { success = true });
        }

        [HttpGet]
        [ActionName("GetLastCountDetailId")]
        public async Task<HttpResponseMessage> GetLastCountDetailId(int intInventoryCountId)
        {
            var bl = _bl as InventoryCountDetailBl;
            var repo = bl.GetRepository() as InventoryRepository;

            //var count = repo.GetQuery<tblICInventoryCount>().OrderByDescending(o => o.intInventoryCountId).FirstOrDefault();

            //var countId = -1;

            //if(count != null)
            //    countId = 1;
            
            //if(countId == -1)
            //    return Request.CreateResponse(HttpStatusCode.NotFound);
            
            var query = repo.GetQuery<tblICInventoryCountDetail>()
                .Where(w => w.intInventoryCountId == intInventoryCountId)
                .GroupBy(o => o.intInventoryCountId)
                .Select(g => new { intCount = g.Count() });
            var last = repo.GetQuery<tblICInventoryCountDetail>()
                .Where(p => p.intInventoryCountId == intInventoryCountId)
                .OrderByDescending(o => o.intInventoryCountDetailId).FirstOrDefault();

            var data = await query.ToListAsync();
            string strCountLine = "";
            if(last != null)
                strCountLine = last.strCountLine.Substring(last.strCountLine.LastIndexOf("-")).Replace("-", "");
            int intCountLine = 1;
            if (int.TryParse(strCountLine, out intCountLine))
                intCountLine++;
            return Request.CreateResponse(HttpStatusCode.OK, new { data = data, strCountLine = strCountLine, intCountLine = intCountLine });
        }

        [HttpPatch]
        [ActionName("UpdateDetail")]
        public async Task<HttpResponseMessage> UpdateDetail(tblICInventoryCountDetail detail)
        {
            var bl = _bl as InventoryCountDetailBl;
            var repo = bl.GetRepository() as InventoryRepository;
            if (ModelState.IsValid && detail != null)
            {
                if(detail.intInventoryCountDetailId == 0)
                    return Request.CreateResponse(HttpStatusCode.BadRequest, new { success = false, msg = "intInventoryCountDetailId or intInventoryCountId is null" });
                try
                {
                    repo.ContextManager.Entry<tblICInventoryCountDetail>(detail).State = EntityState.Modified;
                    await repo.ContextManager.SaveChangesAsync();
                    return Request.CreateResponse(HttpStatusCode.Accepted, new { success = true });
                }
                catch(Exception ex)
                {
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, new { success = false, message = ex.Message + (ex.InnerException != null ? ex.InnerException.Message : "") });
                }
            }
            return Request.CreateResponse(HttpStatusCode.BadRequest);
        }
    }
}