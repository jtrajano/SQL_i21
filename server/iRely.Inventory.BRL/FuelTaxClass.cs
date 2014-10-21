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
    public class FuelTaxClass : IDisposable
    {
        private Repository _db;

        public FuelTaxClass()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICFuelTaxClass> GetSearchQuery()
        {
            return _db.GetQuery<tblICFuelTaxClass>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICFuelTaxClass, bool>> predicate)
        {
            return GetSearchQuery()
                .Include(p => p.tblICFuelTaxClassProductCodes)
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICFuelTaxClass, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICFuelTaxClass> GetTaxClasses(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICFuelTaxClass, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICFuelTaxClass>()
                .Where(w => query.Where(predicate).Any(a => a.intFuelTaxClassId == w.intFuelTaxClassId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddTaxClass(tblICFuelTaxClass taxclass)
        {
            _db.AddNew<tblICFuelTaxClass>(taxclass);
        }

        public void UpdateTaxClass(tblICFuelTaxClass taxclass)
        {
            _db.UpdateBatch<tblICFuelTaxClass>(taxclass);
        }

        public void DeleteTaxClass(tblICFuelTaxClass taxclass)
        {
            _db.Delete<tblICFuelTaxClass>(taxclass);
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
