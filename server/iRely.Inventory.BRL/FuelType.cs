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
    public class FuelType : IDisposable
    {
        private Repository _db;

        public FuelType()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<FuelTypeVM> GetSearchQuery()
        {
            return _db.GetQuery<tblICFuelType>()
                .Select(p => new FuelTypeVM
                {
                    intFuelTypeId = p.intFuelTypeId,
                    strRinFuelTypeCodeId = p.RinFuelType.strRinFuelTypeCode,
                    strRinFeedStockId = p.RinFeedStock.strRinFeedStockCode,
                    strRinFuelId = p.RinFuel.strRinFuelCode,
                    strRinProcessId = p.RinProcess.strRinProcessCode
                });
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<FuelTypeVM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<FuelTypeVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICFuelType> GetFuelTypes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<FuelTypeVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICFuelType>()
                      .Where(w => query.Where(predicate).Any(a => a.intFuelTypeId == w.intFuelTypeId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddFuelType(tblICFuelType FuelType)
        {
            _db.AddNew<tblICFuelType>(FuelType);
        }

        public void UpdateFuelType(tblICFuelType FuelType)
        {
            _db.UpdateBatch<tblICFuelType>(FuelType);
        }

        public void DeleteFuelType(tblICFuelType FuelType)
        {
            _db.Delete<tblICFuelType>(FuelType);
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
