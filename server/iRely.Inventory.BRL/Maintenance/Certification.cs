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
    public class Certification : IDisposable
    {
        private Repository _db;

        public Certification()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCertification> GetSearchQuery()
        {
            return _db.GetQuery<tblICCertification>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCertification, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCertification, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCertification> GetCertifications(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCertification, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCertification>()
                .Include("tblICCertificationCommodities.tblICCommodity")
                .Include("tblICCertificationCommodities.tblSMCurrency")
                .Include("tblICCertificationCommodities.tblICUnitMeasure")
                .Where(w => query.Where(predicate).Any(a => a.intCertificationId == w.intCertificationId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCertification(tblICCertification certification)
        {
            _db.AddNew<tblICCertification>(certification);
        }

        public void UpdateCertification(tblICCertification certification)
        {
            _db.UpdateBatch<tblICCertification>(certification);
        }

        public void DeleteCertification(tblICCertification certification)
        {
            _db.Delete<tblICCertification>(certification);
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
