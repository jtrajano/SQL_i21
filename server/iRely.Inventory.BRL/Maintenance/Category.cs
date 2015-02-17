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
    public class Category : IDisposable
    {
        private Repository _db;

        public Category()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICCategory> GetSearchQuery()
        {
            return _db.GetQuery<tblICCategory>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICCategory, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICCategory, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCategory> GetCategories(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICCategory, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCategory>()
                .Include("tblICCategoryAccounts.tblGLAccount")
                .Include("tblICCategoryAccounts.tblGLAccountCategory")
                .Include("tblICCategoryLocations.tblSMCompanyLocation")
                .Include("tblICCategoryVendors.vyuAPVendor")
                .Include("tblICCategoryVendors.tblICCategoryLocation.tblSMCompanyLocation")
                .Include("tblICCategoryUOMs.tblICUnitMeasure")
                .Where(w => query.Where(predicate).Any(a => a.intCategoryId == w.intCategoryId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCategory(tblICCategory category)
        {
            _db.AddNew<tblICCategory>(category);
        }

        public void UpdateCategory(tblICCategory category)
        {
            _db.UpdateBatch<tblICCategory>(category);
        }

        public void DeleteCategory(tblICCategory category)
        {
            _db.Delete<tblICCategory>(category);
        }

        public SaveResult Save(bool continueOnConflict)
        {
            var result = _db.Save(continueOnConflict);
            var errMessage = result.Exception.Message;
            
            if (errMessage.Contains("Cannot insert the value NULL into column 'intCostingMethod'"))
                errMessage = "Please specify a valid Costing Method.";

            result.Exception = new ServerException(
                new Exception(errMessage),
                result.Exception.Error,
                result.Exception.Button
            );

            return result;
        }
        
        public void Dispose()
        {
            _db.Dispose();
        }
    }
}
