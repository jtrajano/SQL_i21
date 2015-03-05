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
    public class StockReservation : IDisposable
    {
        private Repository _db;

        public StockReservation()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICStockReservation> GetSearchQuery()
        {
            return _db.GetQuery<tblICStockReservation>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICStockReservation, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICStockReservation, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICStockReservation> GetStockReservations(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICStockReservation, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICStockReservation>()
                .Where(w => query.Where(predicate).Any(a => a.intStockReservationId == w.intStockReservationId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddStockReservation(tblICStockReservation reservation)
        {
            _db.AddNew<tblICStockReservation>(reservation);
        }

        public void UpdateStockReservation(tblICStockReservation reservation)
        {
            _db.UpdateBatch<tblICStockReservation>(reservation);
        }

        public void DeleteStockReservation(tblICStockReservation reservation)
        {
            _db.Delete<tblICStockReservation>(reservation);
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
