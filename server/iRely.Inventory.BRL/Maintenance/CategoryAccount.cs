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
    public class CategoryAccount : IDisposable
    {
        private Repository _db;

        public CategoryAccount()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCategoryAccount> GetSearchQuery()
        {
            return _db.GetQuery<tblICCategoryAccount>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryAccount, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCategoryAccount, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCategoryAccount> GetCategoryAccounts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCategoryAccount, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCategoryAccount>()
                .Include(p => p.tblGLAccount)
                .Include(p => p.tblGLAccountCategory)
                .Where(w => query.Where(predicate).Any(a => a.intCategoryAccountId == w.intCategoryAccountId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCategoryAccount(tblICCategoryAccount account)
        {
            _db.AddNew<tblICCategoryAccount>(account);
        }

        public void UpdateCategoryAccount(tblICCategoryAccount account)
        {
            _db.UpdateBatch<tblICCategoryAccount>(account);
        }

        public void DeleteCategoryAccount(tblICCategoryAccount account)
        {
            _db.Delete<tblICCategoryAccount>(account);
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
