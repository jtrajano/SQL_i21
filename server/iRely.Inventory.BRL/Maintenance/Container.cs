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
    public class Container : IDisposable
    {
        private Repository _db;

        public Container()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICContainer> GetSearchQuery()
        {
            return _db.GetQuery<tblICContainer>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICContainer, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICContainer, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICContainer> GetContainers(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICContainer, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICContainer>()
                .Where(w => query.Where(predicate).Any(a => a.intContainerId == w.intContainerId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddContainer(tblICContainer container)
        {
            _db.AddNew<tblICContainer>(container);
        }

        public void UpdateContainer(tblICContainer container)
        {
            _db.UpdateBatch<tblICContainer>(container);
        }

        public void DeleteContainer(tblICContainer container)
        {
            _db.Delete<tblICContainer>(container);
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
