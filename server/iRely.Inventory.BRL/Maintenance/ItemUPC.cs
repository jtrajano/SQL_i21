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
    public class ItemUPC : IDisposable
    {
        private Repository _db;

        public ItemUPC()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemUPC> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemUPC>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemUPC, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemUPC, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemUPC> GetItemUPCs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemUPC, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemUPC>()
                .Include(p => p.tblICUnitMeasure)
                .Where(w => query.Where(predicate).Any(a => a.intItemUPCId == w.intItemUPCId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemUPC(tblICItemUPC upc)
        {
            _db.AddNew<tblICItemUPC>(upc);
        }

        public void UpdateItemUPC(tblICItemUPC upc)
        {
            _db.UpdateBatch<tblICItemUPC>(upc);
        }

        public void DeleteItemUPC(tblICItemUPC upc)
        {
            _db.Delete<tblICItemUPC>(upc);
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
