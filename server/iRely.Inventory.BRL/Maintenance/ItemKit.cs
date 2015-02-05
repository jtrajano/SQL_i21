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
    public class ItemKit : IDisposable
    {
        private Repository _db;

        public ItemKit()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemKit> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemKit>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemKit, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemKit, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemKit> GetItemKits(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemKit, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemKit>()
                .Include("tblICItemKitDetails.tblICItem")
                .Include("tblICItemKitDetails.tblICItemUOM")
                .Where(w => query.Where(predicate).Any(a => a.intItemKitId == w.intItemKitId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemKit(tblICItemKit kit)
        {
            _db.AddNew<tblICItemKit>(kit);
        }

        public void UpdateItemKit(tblICItemKit kit)
        {
            _db.UpdateBatch<tblICItemKit>(kit);
        }

        public void DeleteItemKit(tblICItemKit kit)
        {
            _db.Delete<tblICItemKit>(kit);
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
