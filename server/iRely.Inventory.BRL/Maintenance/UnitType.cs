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
    public class StorageUnitType : IDisposable
    {
        private Repository _db;

        public StorageUnitType()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICStorageUnitType> GetSearchQuery()
        {
            return _db.GetQuery<tblICStorageUnitType>();

        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICStorageUnitType, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICStorageUnitType, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICStorageUnitType> GetStorageUnitTypes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICStorageUnitType, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICStorageUnitType>()
                      .Where(w => query.Where(predicate).Any(a => a.intStorageUnitTypeId == w.intStorageUnitTypeId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddStorageUnitType(tblICStorageUnitType StorageUnitType)
        {
            _db.AddNew<tblICStorageUnitType>(StorageUnitType);
        }

        public void UpdateStorageUnitType(tblICStorageUnitType StorageUnitType)
        {
            _db.UpdateBatch<tblICStorageUnitType>(StorageUnitType);
        }

        public void DeleteStorageUnitType(tblICStorageUnitType StorageUnitType)
        {
            _db.Delete<tblICStorageUnitType>(StorageUnitType);
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
