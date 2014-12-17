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
    public class ItemCertification : IDisposable
    {
        private Repository _db;

        public ItemCertification()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemCertification> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemCertification>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemCertification, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemCertification, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemCertification> GetItemCertifications(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemCertification, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemCertification>()
                .Include(p => p.tblICCertification)
                .Where(w => query.Where(predicate).Any(a => a.intItemCertificationId == w.intItemCertificationId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemCertification(tblICItemCertification certificate)
        {
            _db.AddNew<tblICItemCertification>(certificate);
        }

        public void UpdateItemCertification(tblICItemCertification certificate)
        {
            _db.UpdateBatch<tblICItemCertification>(certificate);
        }

        public void DeleteItemCertification(tblICItemCertification certificate)
        {
            _db.Delete<tblICItemCertification>(certificate);
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
