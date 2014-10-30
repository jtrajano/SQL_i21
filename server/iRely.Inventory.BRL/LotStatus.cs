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
    public class LotStatus : IDisposable
    {
        private Repository _db;

        public LotStatus()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICLotStatus> GetSearchQuery()
        {
            return _db.GetQuery<tblICLotStatus>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICLotStatus, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICLotStatus, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICLotStatus> GetLotStatuses(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICLotStatus, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICLotStatus>()
                .Where(w => query.Where(predicate).Any(a => a.intLotStatusId == w.intLotStatusId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddLotStatus(tblICLotStatus status)
        {
            _db.AddNew<tblICLotStatus>(status);
        }

        public void UpdateLotStatus(tblICLotStatus status)
        {
            _db.UpdateBatch<tblICLotStatus>(status);
        }

        public void DeleteLotStatus(tblICLotStatus status)
        {
            _db.Delete<tblICLotStatus>(status);
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
