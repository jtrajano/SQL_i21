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
    public class MaterialNMFC : IDisposable
    {
        private Repository _db;

        public MaterialNMFC()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICMaterialNMFC> GetSearchQuery()
        {
            return _db.GetQuery<tblICMaterialNMFC>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICMaterialNMFC, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICMaterialNMFC, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICMaterialNMFC> GetMaterialNMFCs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICMaterialNMFC, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICMaterialNMFC>()
                .Where(w => query.Where(predicate).Any(a => a.intMaterialNMFCId == w.intMaterialNMFCId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddMaterialNMFC(tblICMaterialNMFC material)
        {
            _db.AddNew<tblICMaterialNMFC>(material);
        }

        public void UpdateMaterialNMFC(tblICMaterialNMFC material)
        {
            _db.UpdateBatch<tblICMaterialNMFC>(material);
        }

        public void DeleteMaterialNMFC(tblICMaterialNMFC material)
        {
            _db.Delete<tblICMaterialNMFC>(material);
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
