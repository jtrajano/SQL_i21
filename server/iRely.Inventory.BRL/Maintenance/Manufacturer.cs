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
    public class Manufacturer : IDisposable
    {
        private Repository _db;

        public Manufacturer()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICManufacturer> GetSearchQuery()
        {
            return _db.GetQuery<tblICManufacturer>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICManufacturer, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICManufacturer, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICManufacturer> GetManufacturers(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICManufacturer, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICManufacturer>()
                      .Where(w => query.Where(predicate).Any(a => a.intManufacturerId == w.intManufacturerId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddManufacturer(tblICManufacturer Manufacturer)
        {
            _db.AddNew<tblICManufacturer>(Manufacturer);
        }

        public void UpdateManufacturer(tblICManufacturer Manufacturer)
        {
            _db.UpdateBatch<tblICManufacturer>(Manufacturer);
        }

        public void DeleteManufacturer(tblICManufacturer Manufacturer)
        {
            _db.Delete<tblICManufacturer>(Manufacturer);
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
