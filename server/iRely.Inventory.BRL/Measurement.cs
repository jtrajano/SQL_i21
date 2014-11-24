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
    public class Measurement : IDisposable
    {
        private Repository _db;

        public Measurement()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICMeasurement> GetSearchQuery()
        {
            return _db.GetQuery<tblICMeasurement>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICMeasurement, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICMeasurement, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICMeasurement> GetMeasurements(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICMeasurement, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICMeasurement>()
                .Where(w => query.Where(predicate).Any(a => a.intMeasurementId == w.intMeasurementId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddMeasurement(tblICMeasurement measurement)
        {
            _db.AddNew<tblICMeasurement>(measurement);
        }

        public void UpdateMeasurement(tblICMeasurement measurement)
        {
            _db.UpdateBatch<tblICMeasurement>(measurement);
        }

        public void DeleteMeasurement(tblICMeasurement measurement)
        {
            _db.Delete<tblICMeasurement>(measurement);
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
