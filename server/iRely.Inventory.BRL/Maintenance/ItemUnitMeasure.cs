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
    public class ItemUnitMeasure : IDisposable
    {
        private Repository _db;

        public ItemUnitMeasure()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemUOM> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemUOM>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemUOM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemUOM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemUOM> GetItemUnitMeasures(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemUOM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemUOM>()
                .Include(p => p.tblICUnitMeasure)
                .Where(w => query.Where(predicate).Any(a => a.intItemUOMId == w.intItemUOMId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemUnitMeasure(tblICItemUOM uom)
        {
            _db.AddNew<tblICItemUOM>(uom);
        }

        public void UpdateItemUnitMeasure(tblICItemUOM uom)
        {
            _db.UpdateBatch<tblICItemUOM>(uom);
        }

        public void DeleteItemUnitMeasure(tblICItemUOM uom)
        {
            _db.Delete<tblICItemUOM>(uom);
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
