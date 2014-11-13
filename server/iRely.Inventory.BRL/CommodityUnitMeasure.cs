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
    public class CommodityUnitMeasure : IDisposable
    {
        private Repository _db;

        public CommodityUnitMeasure()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCommodityUnitMeasure> GetSearchQuery()
        {
            return _db.GetQuery<tblICCommodityUnitMeasure>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityUnitMeasure, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCommodityUnitMeasure, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCommodityUnitMeasure> GetCommodityUnitMeasures(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCommodityUnitMeasure, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCommodityUnitMeasure>()
                .Include(p=> p.tblICUnitMeasure)
                .Where(w => query.Where(predicate).Any(a => a.intCommodityUnitMeasureId == w.intCommodityUnitMeasureId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCommodityUnitMeasure(tblICCommodityUnitMeasure uom)
        {
            _db.AddNew<tblICCommodityUnitMeasure>(uom);
        }

        public void UpdateCommodityUnitMeasure(tblICCommodityUnitMeasure uom)
        {
            _db.UpdateBatch<tblICCommodityUnitMeasure>(uom);
        }

        public void DeleteCommodityUnitMeasure(tblICCommodityUnitMeasure uom)
        {
            _db.Delete<tblICCommodityUnitMeasure>(uom);
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
