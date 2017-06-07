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

        [HttpPut]
        [ActionName("UpdateDetail")]
        public async Task<HttpResponseMessage> UpdateDetail(tblICInventoryCountDetail detail)
        {
            var bl = _bl as InventoryCountDetailBl;
            var repo = bl.GetRepository() as InventoryRepository;
            if (ModelState.IsValid && detail != null)
            {
                if(detail.intInventoryCountDetailId == 0)
                    return Request.CreateResponse(HttpStatusCode.BadRequest, new { success = false, msg = "intInventoryCountDetailId or intInventoryCountId is null" });
                var d = repo.ContextManager.Entry<tblICInventoryCountDetail>(repo.GetQuery<tblICInventoryCountDetail>().First(t => t.intInventoryCountDetailId == detail.intInventoryCountDetailId));
                if (d != null)
                {
                    if (detail.dblPhysicalCount != null)
                    {
                        d.Property(e => e.dblPhysicalCount).CurrentValue = detail.dblPhysicalCount;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }
                    if (detail.intItemUOMId != null)
                    {
                        d.Property(e => e.intItemUOMId).CurrentValue = detail.intItemUOMId;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }
                    if(detail.intItemId != null)
                    {
                        d.Property(e => e.intItemId).CurrentValue = detail.intItemId;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }
                    if (detail.intLotId != null)
                    {
                        d.Property(e => e.intLotId).CurrentValue = detail.intLotId;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (detail.intStorageLocationId != null)
                    {
                        d.Property(e => e.intStorageLocationId).CurrentValue = detail.intStorageLocationId;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }
                    if (detail.intSubLocationId != null)
                    {
                        d.Property(e => e.intSubLocationId).CurrentValue = detail.intSubLocationId;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }
                    if (detail.dblPallets != null)
                    {
                        d.Property(e => e.dblPallets).CurrentValue = detail.dblPallets;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }
                    if (detail.dblQtyPerPallet != null)
                    {
                        d.Property(e => e.dblQtyPerPallet).CurrentValue = detail.dblQtyPerPallet;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (detail.ysnRecount != null)
                    {
                        d.Property(e => e.ysnRecount).CurrentValue = detail.ysnRecount;
                        d.State = System.Data.Entity.EntityState.Modified;
                    }

                    if (d.State == System.Data.Entity.EntityState.Modified)
                        await repo.SaveAsync(true);
                }
            }

            return Request.CreateResponse(HttpStatusCode.Accepted, new { success = true } );
        }
    }
}