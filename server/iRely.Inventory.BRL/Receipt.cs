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
    public class Receipt : IDisposable
    {
        private Repository _db;

        public Receipt()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICInventoryReceipt> GetSearchQuery()
        {
            return _db.GetQuery<tblICInventoryReceipt>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICInventoryReceipt, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICInventoryReceipt, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICInventoryReceipt> GetReceipts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICInventoryReceipt, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICInventoryReceipt>()
                .Include(p => p.tblICInventoryReceiptInspections)
                .Include("tblICInventoryReceiptItems.tblICInventoryReceiptItemLots")
                .Include("tblICInventoryReceiptItems.tblICInventoryReceiptItemTaxes")
                .Where(w => query.Where(predicate).Any(a => a.intInventoryReceiptId == w.intInventoryReceiptId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddReceipt(tblICInventoryReceipt receipt)
        {
            _db.AddNew<tblICInventoryReceipt>(receipt);
        }

        public void UpdateReceipt(tblICInventoryReceipt receipt)
        {
            _db.UpdateBatch<tblICInventoryReceipt>(receipt);
        }

        public void DeleteReceipt(tblICInventoryReceipt receipt)
        {
            _db.Delete<tblICInventoryReceipt>(receipt);
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
