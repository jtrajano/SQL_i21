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
    public class Catalog : IDisposable
    {
        private Repository _db;

        public Catalog()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCatalog> GetSearchQuery()
        {
            return _db.GetQuery<tblICCatalog>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCatalog, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCatalog, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCatalog> GetCatalogs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCatalog, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCatalog>()
                .Where(w => query.Where(predicate).Any(a => a.intCatalogId == w.intCatalogId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCatalog> GetCatalogs(int intParentId)
        {
            return _db.GetQuery<tblICCatalog>()
                .Where(p => p.intParentCatalogId == intParentId)
                .OrderBy(p => p.intSort).ThenBy(p => p.intCatalogId)
                .AsNoTracking();
        }

        public void AddCatalog(tblICCatalog catalog)
        {
            _db.AddNew<tblICCatalog>(catalog);
        }

        public void UpdateCatalog(tblICCatalog catalog)
        {
            _db.UpdateBatch<tblICCatalog>(catalog);
        }

        public void DeleteCatalog(tblICCatalog catalog)
        {
            _db.Delete<tblICCatalog>(catalog);
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
