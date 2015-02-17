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
    public class ItemPricing : IDisposable
    {
        private Repository _db;

        public ItemPricing()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemPricing> GetPricingSearchQuery()
        {
            return _db.GetQuery<tblICItemPricing>();
        }

        public object GetPricingSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemPricing, bool>> predicate)
        {
            return GetPricingSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetPricingCount(Expression<Func<tblICItemPricing, bool>> predicate)
        {
            return GetPricingSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemPricing> GetItemPricings(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemPricing, bool>> predicate)
        {
            var query = GetPricingSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemPricing>()
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemPricingId == w.intItemPricingId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<vyuICGetItemPricing> GetItemPricingViews(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<vyuICGetItemPricing, bool>> predicate)
        {
            return _db.GetQuery<vyuICGetItemPricing>()
                .Where(predicate) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemPricing(tblICItemPricing pricing)
        {
            _db.AddNew<tblICItemPricing>(pricing);
        }

        public void UpdateItemPricing(tblICItemPricing pricing)
        {
            _db.UpdateBatch<tblICItemPricing>(pricing);
        }

        public void DeleteItemPricing(tblICItemPricing pricing)
        {
            _db.Delete<tblICItemPricing>(pricing);
        }

        public IQueryable<tblICItemPricingLevel> GetPricingLevelSearchQuery()
        {
            return _db.GetQuery<tblICItemPricingLevel>();
        }

        public object GetPricingLevelSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemPricingLevel, bool>> predicate)
        {
            return GetPricingLevelSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetPricingLevelCount(Expression<Func<tblICItemPricingLevel, bool>> predicate)
        {
            return GetPricingLevelSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemPricingLevel> GetItemPricingLevels(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemPricingLevel, bool>> predicate)
        {
            var query = GetPricingLevelSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemPricingLevel>()
                .Include("tblICItemUOM.tblICUnitMeasure")
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemPricingLevelId == w.intItemPricingLevelId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemPricingLevel(tblICItemPricingLevel level)
        {
            _db.AddNew<tblICItemPricingLevel>(level);
        }

        public void UpdateItemPricingLevel(tblICItemPricingLevel level)
        {
            _db.UpdateBatch<tblICItemPricingLevel>(level);
        }

        public void DeleteItemPricingLevel(tblICItemPricingLevel level)
        {
            _db.Delete<tblICItemPricingLevel>(level);
        }

        public IQueryable<tblICItemSpecialPricing> GetSpecialPricingSearchQuery()
        {
            return _db.GetQuery<tblICItemSpecialPricing>();
        }

        public object GetSpecialPricingSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemSpecialPricing, bool>> predicate)
        {
            return GetSpecialPricingSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetSpecialPricingCount(Expression<Func<tblICItemSpecialPricing, bool>> predicate)
        {
            return GetSpecialPricingSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemSpecialPricing> GetItemSpecialPricings(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemSpecialPricing, bool>> predicate)
        {
            var query = GetSpecialPricingSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemSpecialPricing>()
                .Include("tblICItemUOM.tblICUnitMeasure")
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemSpecialPricingId == w.intItemSpecialPricingId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemSpecialPricing(tblICItemSpecialPricing specialPricing)
        {
            _db.AddNew<tblICItemSpecialPricing>(specialPricing);
        }

        public void UpdateItemSpecialPricing(tblICItemSpecialPricing specialPricing)
        {
            _db.UpdateBatch<tblICItemSpecialPricing>(specialPricing);
        }

        public void DeleteItemSpecialPricing(tblICItemSpecialPricing specialPricing)
        {
            _db.Delete<tblICItemSpecialPricing>(specialPricing);
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
