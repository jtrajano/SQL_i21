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
    public class Sku : IDisposable
    {
        private Repository _db;

        public Sku()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICSku> GetSearchQuery()
        {
            return _db.GetQuery<tblICSku>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICSku, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICSku, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICSku> GetSkus(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICSku, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICSku>()
                .Where(w => query.Where(predicate).Any(a => a.intSKUId == w.intSKUId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddSku(tblICSku sku)
        {
            _db.AddNew<tblICSku>(sku);
        }

        public void UpdateSku(tblICSku sku)
        {
            _db.UpdateBatch<tblICSku>(sku);
        }

        public void DeleteSku(tblICSku sku)
        {
            _db.Delete<tblICSku>(sku);
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
