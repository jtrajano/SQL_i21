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
    public class CategoryUOM : IDisposable
    {
        private Repository _db;

        public CategoryUOM()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCategoryUOM> GetSearchQuery()
        {
            return _db.GetQuery<tblICCategoryUOM>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryUOM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCategoryUOM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCategoryUOM> GetCategoryUOMs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryUOM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCategoryUOM>()
                .Include(p => p.tblICUnitMeasure)
                .Include(p => p.WeightUOM)
                .Include(p => p.DimensionUOM)
                .Include(p => p.VolumeUOM)
                .Where(w => query.Where(predicate).Any(a => a.intCategoryUOMId == w.intCategoryUOMId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCategoryUOM(tblICCategoryUOM uom)
        {
            _db.AddNew<tblICCategoryUOM>(uom);
        }

        public void UpdateCategoryUOM(tblICCategoryUOM uom)
        {
            _db.UpdateBatch<tblICCategoryUOM>(uom);
        }

        public void DeleteCategoryUOM(tblICCategoryUOM uom)
        {
            _db.Delete<tblICCategoryUOM>(uom);
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
