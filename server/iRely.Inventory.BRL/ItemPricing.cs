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

        public IQueryable<tblICItemPricing> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemPricing>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemPricing, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemPricing, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemPricing> GetItemPricings(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemPricing, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemPricing>()
                .Include(p => p.tblSMCompanyLocation)
                .Where(w => query.Where(predicate).Any(a => a.intItemPricingId == w.intItemPricingId)) //Filter the Main DataSource Based on Search Query
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
