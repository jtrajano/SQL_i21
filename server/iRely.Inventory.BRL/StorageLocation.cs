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
    public class StorageLocation : IDisposable
    {
        private Repository _db;

        public StorageLocation()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICStorageLocation> GetSearchQuery()
        {
            return _db.GetQuery<tblICStorageLocation>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICStorageLocation, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICStorageLocation, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICStorageLocation> GetStorageLocations(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICStorageLocation, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICStorageLocation>()
                .Include("tblICStorageLocationCategories.tblICCategory")
                .Include("tblICStorageLocationMeasurements.tblICMeasurement")
                .Include("tblICStorageLocationMeasurements.tblICReadingPoint")
                .Include("tblICStorageLocationSkus.tblICItem")
                .Include("tblICStorageLocationSkus.tblICSku")
                .Include("tblICStorageLocationSkus.tblICContainer")
                .Include("tblICStorageLocationSkus.tblICLotStatus")
                .Include("tblICStorageLocationContainers.tblICContainer")
                .Include("tblICStorageLocationContainers.tblICContainerType")
                .Where(w => query.Where(predicate).Any(a => a.intStorageLocationId == w.intStorageLocationId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddStorageLocation(tblICStorageLocation location)
        {
            _db.AddNew<tblICStorageLocation>(location);
        }

        public void UpdateStorageLocation(tblICStorageLocation location)
        {
            _db.UpdateBatch<tblICStorageLocation>(location);
        }

        public void DeleteStorageLocation(tblICStorageLocation location)
        {
            _db.Delete<tblICStorageLocation>(location);
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
