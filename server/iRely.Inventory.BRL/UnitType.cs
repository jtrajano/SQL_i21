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
    public class UnitType : IDisposable
    {
        private Repository _db;

        public UnitType()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICUnitType> GetSearchQuery()
        {
            return _db.GetQuery<tblICUnitType>();

        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICUnitType, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICUnitType, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICUnitType> GetUnitTypes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICUnitType, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICUnitType>()
                      .Where(w => query.Where(predicate).Any(a => a.intUnitTypeId == w.intUnitTypeId)) //Filter the Main DataSource Based on Search Query
                      .OrderBySelector(sortSelector)
                      .Skip(start)
                      .Take(limit)
                      .AsNoTracking();
        }

        public void AddUnitType(tblICUnitType UnitType)
        {
            _db.AddNew<tblICUnitType>(UnitType);
        }

        public void UpdateUnitType(tblICUnitType UnitType)
        {
            _db.UpdateBatch<tblICUnitType>(UnitType);
        }

        public void DeleteUnitType(tblICUnitType UnitType)
        {
            _db.Delete<tblICUnitType>(UnitType);
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
