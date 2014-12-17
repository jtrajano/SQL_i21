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
    public class FuelCategory : IDisposable
    {
        private Repository _db;

        public FuelCategory()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRinFuelCategory> GetSearchQuery()
        {
            return _db.GetQuery<tblICRinFuelCategory>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRinFuelCategory, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRinFuelCategory, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRinFuelCategory> GetFuelCategories(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRinFuelCategory, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRinFuelCategory>()
                      .Where(w => query.Where(predicate).Any(a => a.intRinFuelCategoryId == w.intRinFuelCategoryId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddFuelCategory(tblICRinFuelCategory category)
        {
            _db.AddNew<tblICRinFuelCategory>(category);
        }

        public void UpdateFuelCategory(tblICRinFuelCategory category)
        {
            _db.UpdateBatch<tblICRinFuelCategory>(category);
        }

        public void DeleteFuelCategory(tblICRinFuelCategory category)
        {
            _db.Delete<tblICRinFuelCategory>(category);
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
