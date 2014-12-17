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
    public class EquipmentLength : IDisposable
    {
        private Repository _db;

        public EquipmentLength()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICEquipmentLength> GetSearchQuery()
        {
            return _db.GetQuery<tblICEquipmentLength>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICEquipmentLength, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICEquipmentLength, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICEquipmentLength> GetEquipmentLengths(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICEquipmentLength, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICEquipmentLength>()
                .Where(w => query.Where(predicate).Any(a => a.intEquipmentLengthId == w.intEquipmentLengthId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddEquipmentLength(tblICEquipmentLength length)
        {
            _db.AddNew<tblICEquipmentLength>(length);
        }

        public void UpdateEquipmentLength(tblICEquipmentLength length)
        {
            _db.UpdateBatch<tblICEquipmentLength>(length);
        }

        public void DeleteEquipmentLength(tblICEquipmentLength length)
        {
            _db.Delete<tblICEquipmentLength>(length);
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
