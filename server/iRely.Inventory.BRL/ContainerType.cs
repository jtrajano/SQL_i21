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
    public class ContainerType : IDisposable
    {
        private Repository _db;

        public ContainerType()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICContainerType> GetSearchQuery()
        {
            return _db.GetQuery<tblICContainerType>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICContainerType, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICContainerType, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICContainerType> GetContainerTypes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICContainerType, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICContainerType>()
                .Where(w => query.Where(predicate).Any(a => a.intContainerTypeId == w.intContainerTypeId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddContainerType(tblICContainerType type)
        {
            _db.AddNew<tblICContainerType>(type);
        }

        public void UpdateContainerType(tblICContainerType type)
        {
            _db.UpdateBatch<tblICContainerType>(type);
        }

        public void DeleteContainerType(tblICContainerType type)
        {
            _db.Delete<tblICContainerType>(type);
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
