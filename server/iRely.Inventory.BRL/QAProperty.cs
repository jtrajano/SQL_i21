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
    public class QAProperty : IDisposable
    {
        private Repository _db;

        public QAProperty()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblMFQAProperty> GetSearchQuery()
        {
            return _db.GetQuery<tblMFQAProperty>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblMFQAProperty, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblMFQAProperty, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblMFQAProperty> GetQAProperties(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblMFQAProperty, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblMFQAProperty>()
                .Where(w => query.Where(predicate).Any(a => a.intQAPropertyId == w.intQAPropertyId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddQAProperty(tblMFQAProperty property)
        {
            _db.AddNew<tblMFQAProperty>(property);
        }

        public void UpdateQAProperty(tblMFQAProperty property)
        {
            _db.UpdateBatch<tblMFQAProperty>(property);
        }

        public void DeleteQAProperty(tblMFQAProperty property)
        {
            _db.Delete<tblMFQAProperty>(property);
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
