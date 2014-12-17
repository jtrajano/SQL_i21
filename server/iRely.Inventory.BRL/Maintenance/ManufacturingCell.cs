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
    public class ManufacturingCell : IDisposable
    {
        private Repository _db;

        public ManufacturingCell()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICManufacturingCell> GetSearchQuery()
        {
            return _db.GetQuery<tblICManufacturingCell>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICManufacturingCell, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICManufacturingCell, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICManufacturingCell> GetManufacturingCells(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICManufacturingCell, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICManufacturingCell>()
                .Include(p => p.tblSMCompanyLocation)
                .Include(p => p.CapacityUnitMeasure)
                .Include(p => p.CapacityRateUnitMeasure)
                .Include("tblICManufacturingCellPackTypes.tblICPackType")
                .Include("tblICManufacturingCellPackTypes.CapacityUnitMeasure")
                .Include("tblICManufacturingCellPackTypes.CapacityRateUnitMeasure")
                .Where(w => query.Where(predicate).Any(a => a.intManufacturingCellId == w.intManufacturingCellId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddManufacturingCell(tblICManufacturingCell cell)
        {
            _db.AddNew<tblICManufacturingCell>(cell);
        }

        public void UpdateManufacturingCell(tblICManufacturingCell cell)
        {
            _db.UpdateBatch<tblICManufacturingCell>(cell);
        }

        public void DeleteManufacturingCell(tblICManufacturingCell cell)
        {
            _db.Delete<tblICManufacturingCell>(cell);
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
