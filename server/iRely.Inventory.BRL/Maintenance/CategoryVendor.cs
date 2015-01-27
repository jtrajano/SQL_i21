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
    public class CategoryVendor : IDisposable
    {
        private Repository _db;

        public CategoryVendor()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCategoryVendor> GetSearchQuery()
        {
            return _db.GetQuery<tblICCategoryVendor>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryVendor, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCategoryVendor, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCategoryVendor> GetCategoryVendors(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryVendor, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCategoryVendor>()
                .Include(p => p.vyuAPVendor)
                .Where(w => query.Where(predicate).Any(a => a.intCategoryVendorId == w.intCategoryVendorId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCategoryVendor(tblICCategoryVendor vendor)
        {
            _db.AddNew<tblICCategoryVendor>(vendor);
        }

        public void UpdateCategoryVendor(tblICCategoryVendor vendor)
        {
            _db.UpdateBatch<tblICCategoryVendor>(vendor);
        }

        public void DeleteCategoryVendor(tblICCategoryVendor vendor)
        {
            _db.Delete<tblICCategoryVendor>(vendor);
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
