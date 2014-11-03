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
    public class CategoryLocation : IDisposable
    {
        private Repository _db;

        public CategoryLocation()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCategoryLocation> GetSearchQuery()
        {
            return _db.GetQuery<tblICCategoryLocation>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryLocation, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCategoryLocation, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCategoryLocation> GetCategoryLocations(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryLocation, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCategoryLocation>()
                .Include(p => p.tblSMCompanyLocation)
                .Where(w => query.Where(predicate).Any(a => a.intCategoryLocationId == w.intCategoryLocationId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCategoryLocation(tblICCategoryLocation location)
        {
            _db.AddNew<tblICCategoryLocation>(location);
        }

        public void UpdateCategoryLocation(tblICCategoryLocation location)
        {
            _db.UpdateBatch<tblICCategoryLocation>(location);
        }

        public void DeleteCategoryLocation(tblICCategoryLocation location)
        {
            _db.Delete<tblICCategoryLocation>(location);
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
