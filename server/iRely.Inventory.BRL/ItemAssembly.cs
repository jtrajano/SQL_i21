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
    public class ItemAssembly : IDisposable
    {
        private Repository _db;

        public ItemAssembly()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemAssembly> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemAssembly>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemAssembly, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemAssembly, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemAssembly> GetItemAssemblies(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemAssembly, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemAssembly>()
                .Include(p => p.AssemblyItem)
                .Include(p => p.tblICUnitMeasure)
                .Where(w => query.Where(predicate).Any(a => a.intItemAssemblyId == w.intItemAssemblyId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemAssembly(tblICItemAssembly assembly)
        {
            _db.AddNew<tblICItemAssembly>(assembly);
        }

        public void UpdateItemAssembly(tblICItemAssembly assembly)
        {
            _db.UpdateBatch<tblICItemAssembly>(assembly);
        }

        public void DeleteItemAssembly(tblICItemAssembly assembly)
        {
            _db.Delete<tblICItemAssembly>(assembly);
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
