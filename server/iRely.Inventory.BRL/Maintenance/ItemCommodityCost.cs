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
    public class ItemCommodityCost : IDisposable
    {
        private Repository _db;

        public ItemCommodityCost()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemCommodityCost> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemCommodityCost>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemCommodityCost, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemCommodityCost, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemCommodityCost> GetItemCommodityCosts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemCommodityCost, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemCommodityCost>()
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemCommodityCostId == w.intItemCommodityCostId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemCommodityCost(tblICItemCommodityCost cost)
        {
            _db.AddNew<tblICItemCommodityCost>(cost);
        }

        public void UpdateItemCommodityCost(tblICItemCommodityCost cost)
        {
            _db.UpdateBatch<tblICItemCommodityCost>(cost);
        }

        public void DeleteItemCommodityCost(tblICItemCommodityCost cost)
        {
            _db.Delete<tblICItemCommodityCost>(cost);
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
