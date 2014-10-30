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
    public class LineOfBusiness : IDisposable
    {
        private Repository _db;

        public LineOfBusiness()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICLineOfBusiness> GetSearchQuery()
        {
            return _db.GetQuery<tblICLineOfBusiness>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICLineOfBusiness, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICLineOfBusiness, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICLineOfBusiness> GetLineOfBusinesses(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICLineOfBusiness, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICLineOfBusiness>()
                .Where(w => query.Where(predicate).Any(a => a.intLineOfBusinessId == w.intLineOfBusinessId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddLineOfBusiness(tblICLineOfBusiness line)
        {
            _db.AddNew<tblICLineOfBusiness>(line);
        }

        public void UpdateLineOfBusiness(tblICLineOfBusiness line)
        {
            _db.UpdateBatch<tblICLineOfBusiness>(line);
        }

        public void DeleteLineOfBusiness(tblICLineOfBusiness line)
        {
            _db.Delete<tblICLineOfBusiness>(line);
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
