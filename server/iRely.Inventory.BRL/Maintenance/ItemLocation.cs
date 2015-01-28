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
    public class ItemLocation : IDisposable
    {
        private Repository _db;

        public ItemLocation()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemLocation> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemLocation>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemLocation, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemLocation, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemLocation> GetItemLocations(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemLocation, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemLocation>()
                .Include(p => p.tblSMCompanyLocation)
                .Include(p => p.vyuAPVendor)
                .Include(p => p.tblICCategory)
                .Where(w => query.Where(predicate).Any(a => a.intItemLocationId == w.intItemLocationId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemLocation(tblICItemLocation location)
        {
            _db.AddNew<tblICItemLocation>(location);
        }

        public void UpdateItemLocation(tblICItemLocation location)
        {
            _db.UpdateBatch<tblICItemLocation>(location);
        }

        public void DeleteItemLocation(tblICItemLocation location)
        {
            _db.Delete<tblICItemLocation>(location);
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
