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
    public class StorageType : IDisposable
    {
        private Repository _db;

        public StorageType()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblGRStorageType> GetSearchQuery()
        {
            return _db.GetQuery<tblGRStorageType>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblGRStorageType, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblGRStorageType, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblGRStorageType> GetStorageTypes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblGRStorageType, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblGRStorageType>()
                .Where(w => query.Where(predicate).Any(a => a.intStorageTypeId == w.intStorageTypeId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddStorageType(tblGRStorageType type)
        {
            _db.AddNew<tblGRStorageType>(type);
        }

        public void UpdateStorageType(tblGRStorageType type)
        {
            _db.UpdateBatch<tblGRStorageType>(type);
        }

        public void DeleteStorageType(tblGRStorageType type)
        {
            _db.Delete<tblGRStorageType>(type);
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
