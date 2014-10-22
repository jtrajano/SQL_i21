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
    public class Brand : IDisposable
    {
        private Repository _db;

        public Brand()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICBrand> GetSearchQuery()
        {
            return _db.GetQuery<tblICBrand>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICBrand, bool>> predicate)
        {
            return GetSearchQuery()
                .Include(p => p.tblICManufacturer)
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICBrand, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICBrand> GetBrands(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICBrand, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICBrand>()
                .Where(w => query.Where(predicate).Any(a => a.intBrandId == w.intBrandId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddBrand(tblICBrand brand)
        {
            _db.AddNew<tblICBrand>(brand);
        }

        public void UpdateBrand(tblICBrand brand)
        {
            _db.UpdateBatch<tblICBrand>(brand);
        }

        public void DeleteBrand(tblICBrand brand)
        {
            _db.Delete<tblICBrand>(brand);
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
