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
    public class ItemAccount : IDisposable
    {
        private Repository _db;

        public ItemAccount()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemAccount> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemAccount>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemAccount, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemAccount, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemAccount> GetItemAccounts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemAccount, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemAccount>()
                .Include(p => p.tblGLAccount)
                .Where(w => query.Where(predicate).Any(a => a.intItemAccountId == w.intItemAccountId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemAccount(tblICItemAccount account)
        {
            _db.AddNew<tblICItemAccount>(account);
        }

        public void UpdateItemAccount(tblICItemAccount account)
        {
            _db.UpdateBatch<tblICItemAccount>(account);
        }

        public void DeleteItemAccount(tblICItemAccount account)
        {
            _db.Delete<tblICItemAccount>(account);
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
