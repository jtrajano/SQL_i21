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
    public class Status : IDisposable
    {
        private Repository _db;

        public Status()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICStatus> GetSearchQuery()
        {
            return _db.GetQuery<tblICStatus>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICStatus, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICStatus, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICStatus> GetStatuses(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICStatus, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICStatus>()
                .Where(w => query.Where(predicate).Any(a => a.intStatusId == w.intStatusId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddStatus(tblICStatus status)
        {
            _db.AddNew<tblICStatus>(status);
        }

        public void UpdateStatus(tblICStatus status)
        {
            _db.UpdateBatch<tblICStatus>(status);
        }

        public void DeleteStatus(tblICStatus status)
        {
            _db.Delete<tblICStatus>(status);
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
