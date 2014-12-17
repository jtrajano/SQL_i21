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
    public class RinFeedStockUOM : IDisposable
    {
        private Repository _db;

        public RinFeedStockUOM()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRinFeedStockUOM> GetSearchQuery()
        {
            return _db.GetQuery<tblICRinFeedStockUOM>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRinFeedStockUOM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRinFeedStockUOM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRinFeedStockUOM> GetRinFeedStockUOMs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRinFeedStockUOM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRinFeedStockUOM>()
                    .Include(p => p.tblICUnitMeasure)
                    .Where(w => query.Where(predicate).Any(a => a.intRinFeedStockUOMId == w.intRinFeedStockUOMId)) //Filter the Main DataSource Based on Search Query
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit)
                    .AsNoTracking();
        }

        public void AddRinFeedStockUOM(tblICRinFeedStockUOM RinFeedStockUOM)
        {
            _db.AddNew<tblICRinFeedStockUOM>(RinFeedStockUOM);
        }

        public void UpdateRinFeedStockUOM(tblICRinFeedStockUOM RinFeedStockUOM)
        {
            _db.UpdateBatch<tblICRinFeedStockUOM>(RinFeedStockUOM);
        }

        public void DeleteRinFeedStockUOM(tblICRinFeedStockUOM RinFeedStockUOM)
        {
            _db.Delete<tblICRinFeedStockUOM>(RinFeedStockUOM);
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
