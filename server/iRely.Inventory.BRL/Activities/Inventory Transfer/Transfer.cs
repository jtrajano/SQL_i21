using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Web;

using iRely.Common;
using iRely.Inventory.Model;
using IdeaBlade.Core;
using IdeaBlade.Linq;

namespace iRely.Inventory.BRL
{
    public class Transfer : IDisposable
    {
        private Repository _db;

        public Transfer()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<TransferVM> GetSearchQuery()
        {
            return _db.GetQuery<tblICInventoryTransfer>()
                .Include(p => p.FromLocation)
                .Include(p => p.ToLocation)
                .Select(p => new TransferVM
                {
                    intInventoryTransferId = p.intInventoryTransferId,
                    strTransferNo = p.strTransferNo,
                    dtmTransferDate = p.dtmTransferDate,
                    strTransferType = p.strTransferType,
                    strDescription = p.strDescription,
                    intFromLocationId = p.intFromLocationId,
                    strFromLocation = p.FromLocation.strLocationName,
                    intToLocationId = p.intToLocationId,
                    strToLocation = p.ToLocation.strLocationName,
                    ysnShipmentRequired = p.ysnShipmentRequired,
                    intSort = p.intSort,
                });
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<TransferVM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<TransferVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICInventoryTransfer> GetTransfers(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<TransferVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICInventoryTransfer>()
                .Include(p => p.tblGLAccount)
                .Include("tblICInventoryTransferDetails.tblICItem")
                .Include("tblICInventoryTransferDetails.tblICItemUOM")
                .Include("tblICInventoryTransferDetails.tblICLot")
                .Include("tblICInventoryTransferDetails.tblSMTaxCode")
                .Include("tblICInventoryTransferDetails.FromSubLocation")
                .Include("tblICInventoryTransferDetails.FromStorageLocation")
                .Include("tblICInventoryTransferDetails.ToSubLocation")
                .Include("tblICInventoryTransferDetails.ToStorageLocation")
                .Include(p => p.tblICInventoryTransferNotes)
                .Where(w => query.Where(predicate).Any(a => a.intInventoryTransferId == w.intInventoryTransferId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddTransfer(tblICInventoryTransfer transfer)
        {
            transfer.strTransferNo = Common.GetStartingNumber(Common.StartingNumber.InventoryTransfer);
            //transfer.intCreatedUserId = iRely.Common.Security.GetUserId();
            //transfer.intEntityId = iRely.Common.Security.GetEntityId();
            _db.AddNew<tblICInventoryTransfer>(transfer);
        }

        public void UpdateTransfer(tblICInventoryTransfer transfer)
        {
            _db.UpdateBatch<tblICInventoryTransfer>(transfer);
        }

        public void DeleteTransfer(tblICInventoryTransfer transfer)
        {
            _db.Delete<tblICInventoryTransfer>(transfer);
        }

        public SaveResult Save(bool continueOnConflict)
        {
            return _db.Save(continueOnConflict);
        }
        
        public void Dispose()
        {
            _db.Dispose();
        }
    }
}
