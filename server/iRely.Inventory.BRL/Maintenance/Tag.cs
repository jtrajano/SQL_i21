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
    public class Tag : IDisposable
    {
        private Repository _db;

        public Tag()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICTag> GetSearchQuery()
        {
            return _db.GetQuery<tblICTag>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICTag, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICTag, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICTag> GetTags(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICTag, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICTag>()
                      .Where(w => query.Where(predicate).Any(a => a.intTagId == w.intTagId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddTag(tblICTag tag)
        {
            _db.AddNew<tblICTag>(tag);
        }

        public void UpdateTag(tblICTag tag)
        {
            _db.UpdateBatch<tblICTag>(tag);
        }

        public void DeleteTag(tblICTag tag)
        {
            _db.Delete<tblICTag>(tag);
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
