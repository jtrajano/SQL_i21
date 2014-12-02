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
    public class ItemPOS : IDisposable
    {
        private Repository _db;

        public ItemPOS()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemPOSCategory> GetPOSCategorySearchQuery()
        {
            return _db.GetQuery<tblICItemPOSCategory>();
        }

        public object GetPOSCategorySearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemPOSCategory, bool>> predicate)
        {
            return GetPOSCategorySearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetPOSCategoryCount(Expression<Func<tblICItemPOSCategory, bool>> predicate)
        {
            return GetPOSCategorySearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemPOSCategory> GetItemPOSCategories(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemPOSCategory, bool>> predicate)
        {
            var query = GetPOSCategorySearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemPOSCategory>()
                .Include(p => p.tblICCategory)
                .Where(w => query.Where(predicate).Any(a => a.intItemPOSCategoryId == w.intItemPOSCategoryId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemPOSCategory(tblICItemPOSCategory category)
        {
            _db.AddNew<tblICItemPOSCategory>(category);
        }

        public void UpdateItemPOSCategory(tblICItemPOSCategory category)
        {
            _db.UpdateBatch<tblICItemPOSCategory>(category);
        }

        public void DeleteItemPOSCategory(tblICItemPOSCategory category)
        {
            _db.Delete<tblICItemPOSCategory>(category);
        }

        public IQueryable<tblICItemPOSSLA> GetPOSSLASearchQuery()
        {
            return _db.GetQuery<tblICItemPOSSLA>();
        }

        public object GetPOSSLASearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemPOSSLA, bool>> predicate)
        {
            return GetPOSSLASearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetPOSSLACount(Expression<Func<tblICItemPOSSLA, bool>> predicate)
        {
            return GetPOSSLASearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemPOSSLA> GetItemPOSSLAs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemPOSSLA, bool>> predicate)
        {
            var query = GetPOSSLASearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemPOSSLA>()
                .Where(w => query.Where(predicate).Any(a => a.intItemPOSSLAId == w.intItemPOSSLAId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemPOSSLA(tblICItemPOSSLA sla)
        {
            _db.AddNew<tblICItemPOSSLA>(sla);
        }

        public void UpdateItemPOSSLA(tblICItemPOSSLA sla)
        {
            _db.UpdateBatch<tblICItemPOSSLA>(sla);
        }

        public void DeleteItemPOSSLA(tblICItemPOSSLA sla)
        {
            _db.Delete<tblICItemPOSSLA>(sla);
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
