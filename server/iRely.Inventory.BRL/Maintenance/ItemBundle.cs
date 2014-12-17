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
    public class ItemBundle : IDisposable
    {
        private Repository _db;

        public ItemBundle()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemBundle> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemBundle>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemBundle, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemBundle, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemBundle> GetItemBundles(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemBundle, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemBundle>()
                .Include(p => p.BundleItem)
                .Include(p => p.tblICUnitMeasure)
                .Where(w => query.Where(predicate).Any(a => a.intItemBundleId == w.intItemBundleId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemBundle(tblICItemBundle bundle)
        {
            _db.AddNew<tblICItemBundle>(bundle);
        }

        public void UpdateItemBundle(tblICItemBundle bundle)
        {
            _db.UpdateBatch<tblICItemBundle>(bundle);
        }

        public void DeleteItemBundle(tblICItemBundle bundle)
        {
            _db.Delete<tblICItemBundle>(bundle);
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
