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
    public class ItemStock : IDisposable
    {
        private Repository _db;

        public ItemStock()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemStock> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemStock>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemStock, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemStock, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemStock> GetItemStocks(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemStock, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemStock>()
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemStockId == w.intItemStockId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemStock(tblICItemStock stock)
        {
            _db.AddNew<tblICItemStock>(stock);
        }

        public void UpdateItemStock(tblICItemStock stock)
        {
            _db.UpdateBatch<tblICItemStock>(stock);
        }

        public void DeleteItemStock(tblICItemStock stock)
        {
            _db.Delete<tblICItemStock>(stock);
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
