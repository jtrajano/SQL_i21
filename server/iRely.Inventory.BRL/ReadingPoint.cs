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
    public class ReadingPoint : IDisposable
    {
        private Repository _db;

        public ReadingPoint()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICReadingPoint> GetSearchQuery()
        {
            return _db.GetQuery<tblICReadingPoint>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICReadingPoint, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICReadingPoint, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICReadingPoint> GetReadingPoints(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICReadingPoint, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICReadingPoint>()
                .Where(w => query.Where(predicate).Any(a => a.intReadingPointId == w.intReadingPointId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddReadingPoint(tblICReadingPoint point)
        {
            _db.AddNew<tblICReadingPoint>(point);
        }

        public void UpdateReadingPoint(tblICReadingPoint point)
        {
            _db.UpdateBatch<tblICReadingPoint>(point);
        }

        public void DeleteReadingPoint(tblICReadingPoint point)
        {
            _db.Delete<tblICReadingPoint>(point);
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
