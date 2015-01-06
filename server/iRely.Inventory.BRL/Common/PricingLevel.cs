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
    public class PricingLevel : IDisposable
    {
        private Repository _db;

        public PricingLevel()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<vyuSMGetLocationPricingLevel> GetSearchQuery()
        {
            return _db.GetQuery<vyuSMGetLocationPricingLevel>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<vyuSMGetLocationPricingLevel, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<vyuSMGetLocationPricingLevel, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<vyuSMGetLocationPricingLevel> GetPricingLevels(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<vyuSMGetLocationPricingLevel, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<vyuSMGetLocationPricingLevel>()
                .Where(w => query.Where(predicate).Any(a => a.intKey == w.intKey)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddPricingLevel(vyuSMGetLocationPricingLevel pricingLevel)
        {
            _db.AddNew<vyuSMGetLocationPricingLevel>(pricingLevel);
        }

        public void UpdatePricingLevel(vyuSMGetLocationPricingLevel pricingLevel)
        {
            _db.UpdateBatch<vyuSMGetLocationPricingLevel>(pricingLevel);
        }

        public void DeletePricingLevel(vyuSMGetLocationPricingLevel pricingLevel)
        {
            _db.Delete<vyuSMGetLocationPricingLevel>(pricingLevel);
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
