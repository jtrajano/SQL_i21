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
    public class CommodityAttribute : IDisposable
    {
        private Repository _db;

        public CommodityAttribute()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCommodityAttribute> GetSearchQuery()
        {
            return _db.GetQuery<tblICCommodityAttribute>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityAttribute, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCommodityAttribute, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCommodityAttribute> GetCommodityAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityAttribute, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCommodityAttribute>()
                .Where(w => query.Where(predicate).Any(a => a.intCommodityAttributeId == w.intCommodityAttributeId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCommodityAttribute(tblICCommodityAttribute attribute)
        {
            _db.AddNew<tblICCommodityAttribute>(attribute);
        }

        public void UpdateCommodityAttribute(tblICCommodityAttribute attribute)
        {
            _db.UpdateBatch<tblICCommodityAttribute>(attribute);
        }

        public void DeleteCommodityAttribute(tblICCommodityAttribute attribute)
        {
            _db.Delete<tblICCommodityAttribute>(attribute);
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
