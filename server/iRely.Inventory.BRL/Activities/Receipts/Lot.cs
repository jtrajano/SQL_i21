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
    public partial class Lot : IDisposable
    {
        private Repository _db;

        public Lot()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICLot> GetSearchQuery()
        {
            return _db.GetQuery<tblICLot>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICLot, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICLot, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICLot> GetLots(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICLot, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICLot>()
                .Include(p => p.tblICItemLocation)
                .Where(w => query.Where(predicate).Any(a => a.intLotId == w.intLotId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddLot(tblICLot lot)
        {
            _db.AddNew<tblICLot>(lot);
        }

        public void UpdateLot(tblICLot lot)
        {
            _db.UpdateBatch<tblICLot>(lot);
        }

        public void DeleteLot(tblICLot lot)
        {
            _db.Delete<tblICLot>(lot);
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
