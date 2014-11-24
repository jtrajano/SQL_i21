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
    public class Restriction : IDisposable
    {
        private Repository _db;

        public Restriction()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRestriction> GetSearchQuery()
        {
            return _db.GetQuery<tblICRestriction>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRestriction, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRestriction, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRestriction> GetRestrictions(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRestriction, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRestriction>()
                .Where(w => query.Where(predicate).Any(a => a.intRestrictionId == w.intRestrictionId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddRestriction(tblICRestriction restriction)
        {
            _db.AddNew<tblICRestriction>(restriction);
        }

        public void UpdateRestriction(tblICRestriction restriction)
        {
            _db.UpdateBatch<tblICRestriction>(restriction);
        }

        public void DeleteRestriction(tblICRestriction restriction)
        {
            _db.Delete<tblICRestriction>(restriction);
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
