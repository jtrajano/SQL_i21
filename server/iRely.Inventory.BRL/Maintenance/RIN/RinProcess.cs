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
    public class RinProcess : IDisposable
    {
        private Repository _db;

        public RinProcess()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRinProcess> GetSearchQuery()
        {
            return _db.GetQuery<tblICRinProcess>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRinProcess, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRinProcess, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRinProcess> GetRinProcesses(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRinProcess, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRinProcess>()
                      .Where(w => query.Where(predicate).Any(a => a.intRinProcessId == w.intRinProcessId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddRinProcess(tblICRinProcess RinProcess)
        {
            _db.AddNew<tblICRinProcess>(RinProcess);
        }

        public void UpdateRinProcess(tblICRinProcess RinProcess)
        {
            _db.UpdateBatch<tblICRinProcess>(RinProcess);
        }

        public void DeleteRinProcess(tblICRinProcess RinProcess)
        {
            _db.Delete<tblICRinProcess>(RinProcess);
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
