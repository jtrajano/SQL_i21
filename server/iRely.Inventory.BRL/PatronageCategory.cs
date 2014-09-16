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
    public class PatronageCategory : IDisposable
    {
        private Repository _db;

        public PatronageCategory()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICPatronageCategory> GetSearchQuery()
        {
            return _db.GetQuery<tblICPatronageCategory>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICPatronageCategory, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICPatronageCategory, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICPatronageCategory> GetPatronageCategories(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICPatronageCategory, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICPatronageCategory>()
                      .Where(w => query.Where(predicate).Any(a => a.intPatronageCategoryId == w.intPatronageCategoryId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddPatronageCategory(tblICPatronageCategory PatronageCategory)
        {
            _db.AddNew<tblICPatronageCategory>(PatronageCategory);
        }

        public void UpdatePatronageCategory(tblICPatronageCategory PatronageCategory)
        {
            _db.UpdateBatch<tblICPatronageCategory>(PatronageCategory);
        }

        public void DeletePatronageCategory(tblICPatronageCategory PatronageCategory)
        {
            _db.Delete<tblICPatronageCategory>(PatronageCategory);
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
