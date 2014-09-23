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
    public class RinFeedStock : IDisposable
    {
        private Repository _db;

        public RinFeedStock()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRinFeedStock> GetSearchQuery()
        {
            return _db.GetQuery<tblICRinFeedStock>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRinFeedStock, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRinFeedStock, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRinFeedStock> GetRinFeedStocks(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRinFeedStock, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRinFeedStock>()
                      .Where(w => query.Where(predicate).Any(a => a.intRinFeedStockId == w.intRinFeedStockId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddRinFeedStock(tblICRinFeedStock RinFeedStock)
        {
            _db.AddNew<tblICRinFeedStock>(RinFeedStock);
        }

        public void UpdateRinFeedStock(tblICRinFeedStock RinFeedStock)
        {
            _db.UpdateBatch<tblICRinFeedStock>(RinFeedStock);
        }

        public void DeleteRinFeedStock(tblICRinFeedStock RinFeedStock)
        {
            _db.Delete<tblICRinFeedStock>(RinFeedStock);
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
