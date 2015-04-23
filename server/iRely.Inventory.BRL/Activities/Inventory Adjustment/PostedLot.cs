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
    public partial class PostedLot : IDisposable
    {
        private Repository _db;

        public PostedLot()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<vyuICGetPostedLot> GetSearchQuery()
        {
            return _db.GetQuery<vyuICGetPostedLot>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<vyuICGetPostedLot, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<vyuICGetPostedLot, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<vyuICGetPostedLot> GetPostedLots(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<vyuICGetPostedLot, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<vyuICGetPostedLot>()
                .Where(w => query.Where(predicate).Any(a => a.intLotId == w.intLotId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void Dispose()
        {
            _db.Dispose();
        }
    }
}
