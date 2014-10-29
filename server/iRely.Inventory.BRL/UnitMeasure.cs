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
    public class UnitMeasure : IDisposable
    {
        private Repository _db;

        public UnitMeasure()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICUnitMeasure> GetSearchQuery()
        {
            return _db.GetQuery<tblICUnitMeasure>();

        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICUnitMeasure, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICUnitMeasure, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICUnitMeasure> GetUnitMeasures(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICUnitMeasure, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICUnitMeasure>()
                    .Include("tblICUnitMeasureConversions.StockUnitMeasure")
                    .Where(w => query.Where(predicate).Any(a => a.intUnitMeasureId == w.intUnitMeasureId)) //Filter the Main DataSource Based on Search Query
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit)
                    .AsNoTracking();
        }

        public void AddUnitMeasure(tblICUnitMeasure UnitMeasure)
        {
            _db.AddNew<tblICUnitMeasure>(UnitMeasure);
        }

        public void UpdateUnitMeasure(tblICUnitMeasure UnitMeasure)
        {
            _db.UpdateBatch<tblICUnitMeasure>(UnitMeasure);
        }

        public void DeleteUnitMeasure(tblICUnitMeasure UnitMeasure)
        {
            _db.Delete<tblICUnitMeasure>(UnitMeasure);
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
