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
    public class RinFuel : IDisposable
    {
        private Repository _db;

        public RinFuel()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICRinFuel> GetSearchQuery()
        {
            return _db.GetQuery<tblICRinFuel>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICRinFuel, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICRinFuel, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICRinFuel> GetRinFuels(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICRinFuel, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICRinFuel>()
                      .Where(w => query.Where(predicate).Any(a => a.intRinFuelId == w.intRinFuelId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddRinFuel(tblICRinFuel RinFuel)
        {
            _db.AddNew<tblICRinFuel>(RinFuel);
        }

        public void UpdateRinFuel(tblICRinFuel RinFuel)
        {
            _db.UpdateBatch<tblICRinFuel>(RinFuel);
        }

        public void DeleteRinFuel(tblICRinFuel RinFuel)
        {
            _db.Delete<tblICRinFuel>(RinFuel);
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
