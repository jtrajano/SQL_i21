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
                bl.Update(detail);
                await repo.SaveAsync(true);
                // var d = repo.ContextManager.Entry<tblICInventoryCountDetail>(repo.GetQuery<tblICInventoryCountDetail>().First(t => t.intInventoryCountDetailId == detail.intInventoryCountDetailId));
                // if (d != null)
                // {
                //     if(detail.dblWeightQty != null)
                //     {
                //         d.Property(e => e.dblWeightQty).CurrentValue = detail.dblWeightQty;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if(detail.dblNetQty != null)
                //     {
                //         d.Property(e => e.dblNetQty).CurrentValue = detail.dblNetQty;
                //         d.State = EntityState.Modified;
                //     }
                //     if (detail.intWeightUOMId != null)
                //     {
                //         d.Property(e => e.intWeightUOMId).CurrentValue = detail.intWeightUOMId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.dblPhysicalCount != null)
                //     {
                //         d.Property(e => e.dblPhysicalCount).CurrentValue = detail.dblPhysicalCount;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.intStockUOMId != null)
                //     {
                //         d.Property(e => e.intStockUOMId).CurrentValue = detail.intStockUOMId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.intItemUOMId != null)
                //     {
                //         d.Property(e => e.intItemUOMId).CurrentValue = detail.intItemUOMId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.intItemId != null)
                //     {
                //         d.Property(e => e.intItemId).CurrentValue = detail.intItemId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }

                //     if (detail.strLotNo != null)
                //     {
                //         d.Property(e => e.intLotId).CurrentValue = detail.intLotId;
                //         d.Property(e => e.strLotNo).CurrentValue = detail.strLotNo;
                //         d.State = EntityState.Modified;
                //     }
                //     if (detail.strLotAlias != null)
                //     {
                //         d.Property(e => e.strLotAlias).CurrentValue = detail.strLotAlias;
                //         d.State = EntityState.Modified;
                //     }
                //     if (detail.intStorageLocationId != null)
                //     {
                //         d.Property(e => e.intStorageLocationId).CurrentValue = detail.intStorageLocationId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.dblSystemCount != null)
                //     {
                //         d.Property(e => e.dblSystemCount).CurrentValue = detail.dblSystemCount;
                //         d.State = EntityState.Modified;
                //     }
                //     if (detail.dblLastCost != null)
                //     {
                //         d.Property(e => e.dblLastCost).CurrentValue = detail.dblLastCost;
                //         d.State = EntityState.Modified;
                //     }
                //     if (detail.dblVariance != null)
                //     {
                //         d.Property(e => e.dblVariance).CurrentValue = detail.dblVariance;
                //         d.State = EntityState.Modified;
                //     }
                //     if (detail.intCountGroupId != null)
                //     {
                //         d.Property(e => e.intCountGroupId).CurrentValue = detail.intCountGroupId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.intCountGroupId == -1)
                //     {
                //         d.Property(e => e.intCountGroupId).CurrentValue = null;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }

                //     if(detail.dblQtyReceived != null)
                //     {
                //         d.Property(e => e.dblQtyReceived).CurrentValue = detail.dblQtyReceived;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }

                //     if (detail.dblQtySold != null)
                //     {
                //         d.Property(e => e.dblQtySold).CurrentValue = detail.dblQtySold;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.intSubLocationId != null)
                //     {
                //         d.Property(e => e.intSubLocationId).CurrentValue = detail.intSubLocationId;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.dblPallets != null)
                //     {
                //         d.Property(e => e.dblPallets).CurrentValue = detail.dblPallets;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }
                //     if (detail.dblQtyPerPallet != null)
                //     {
                //         d.Property(e => e.dblQtyPerPallet).CurrentValue = detail.dblQtyPerPallet;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }

                //     if (detail.ysnRecount != null)
                //     {
                //         d.Property(e => e.ysnRecount).CurrentValue = detail.ysnRecount;
                //         d.State = System.Data.Entity.EntityState.Modified;
                //     }

                //     if (d.State == System.Data.Entity.EntityState.Modified)
                //         await repo.SaveAsync(true);
                // }
            }

            return Request.CreateResponse(HttpStatusCode.Accepted, new { success = true } );
        }
    }
}