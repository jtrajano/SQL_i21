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

        public int GetOriginCount(Expression<Func<tblICCommodityOrigin, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityOrigin>().Where(predicate).Count();
        }

        public int GetRegionCount(Expression<Func<tblICCommodityRegion, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityRegion>().Where(predicate).Count();
        }

        public int GetProductTypeCount(Expression<Func<tblICCommodityProductType, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityProductType>().Where(predicate).Count();
        }

        public int GetSeasonCount(Expression<Func<tblICCommoditySeason, bool>> predicate)
        {
            return _db.GetQuery<tblICCommoditySeason>().Where(predicate).Count();
        }

        public int GetClassCount(Expression<Func<tblICCommodityClassVariant, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityClassVariant>().Where(predicate).Count();
        }

        public int GetProductLineCount(Expression<Func<tblICCommodityProductLine, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityProductLine>().Where(predicate).Count();
        }

        public int GetGradeCount(Expression<Func<tblICCommodityGrade, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityGrade>().Where(predicate).Count();
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

        public IQueryable<tblICCommodityOrigin> GetOriginAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityOrigin, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityOrigin>()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCommodityProductType> GetProductTypeAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityProductType, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityProductType>()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCommodityRegion> GetRegionAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityRegion, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityRegion>()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCommoditySeason> GetSeasonAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommoditySeason, bool>> predicate)
        {
            return _db.GetQuery<tblICCommoditySeason>()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCommodityClassVariant> GetClassAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityClassVariant, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCommodityClassVariant>()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCommodityProductLine> GetProductLineAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityProductLine, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityProductLine>()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICCommodityGrade> GetGradeAttributes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityGrade, bool>> predicate)
        {
            return _db.GetQuery<tblICCommodityGrade>()
                .Where(predicate)
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
