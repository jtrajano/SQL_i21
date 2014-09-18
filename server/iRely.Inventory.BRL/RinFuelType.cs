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
    public class RinFuelType : IDisposable
    {
        private Repository _db;

        public RinFuelType()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRinFuelType> GetSearchQuery()
        {
            return _db.GetQuery<tblICRinFuelType>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRinFuelType, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRinFuelType, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRinFuelType> GetRinFuelTypes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRinFuelType, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRinFuelType>()
                      .Where(w => query.Where(predicate).Any(a => a.intRinFuelTypeId == w.intRinFuelTypeId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddRinFuelType(tblICRinFuelType RinFuelType)
        {
            _db.AddNew<tblICRinFuelType>(RinFuelType);
        }

        public void UpdateRinFuelType(tblICRinFuelType RinFuelType)
        {
            _db.UpdateBatch<tblICRinFuelType>(RinFuelType);
        }

        public void DeleteRinFuelType(tblICRinFuelType RinFuelType)
        {
            _db.Delete<tblICRinFuelType>(RinFuelType);
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
