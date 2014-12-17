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
    public class ReceiptItemTax : IDisposable
    {
        private Repository _db;

        public ReceiptItemTax()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICInventoryReceiptItemTax> GetSearchQuery()
        {
            return _db.GetQuery<tblICInventoryReceiptItemTax>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICInventoryReceiptItemTax, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICInventoryReceiptItemTax, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICInventoryReceiptItemTax> GetReceiptItemTaxes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICInventoryReceiptItemTax, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICInventoryReceiptItemTax>()
                .Where(w => query.Where(predicate).Any(a => a.intInventoryReceiptItemTaxId == w.intInventoryReceiptItemTaxId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddReceiptItemTax(tblICInventoryReceiptItemTax tax)
        {
            _db.AddNew<tblICInventoryReceiptItemTax>(tax);
        }

        public void UpdateReceiptItemTax(tblICInventoryReceiptItemTax tax)
        {
            _db.UpdateBatch<tblICInventoryReceiptItemTax>(tax);
        }

        public void DeleteReceiptItemTax(tblICInventoryReceiptItemTax tax)
        {
            _db.Delete<tblICInventoryReceiptItemTax>(tax);
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
