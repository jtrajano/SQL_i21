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
    public class CountGroup : IDisposable
    {
        private Repository _db;

        public CountGroup()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCountGroup> GetSearchQuery()
        {
            return _db.GetQuery<tblICCountGroup>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCountGroup, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCountGroup, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCountGroup> GetCountGroups(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCountGroup, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCountGroup>()
                .Where(w => query.Where(predicate).Any(a => a.intCountGroupId == w.intCountGroupId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCountGroup(tblICCountGroup group)
        {
            _db.AddNew<tblICCountGroup>(group);
        }

        public void UpdateCountGroup(tblICCountGroup group)
        {
            _db.UpdateBatch<tblICCountGroup>(group);
        }

        public void DeleteCountGroup(tblICCountGroup group)
        {
            _db.Delete<tblICCountGroup>(group);
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
