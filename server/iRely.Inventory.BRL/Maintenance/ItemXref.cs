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
    public class ItemXref : IDisposable
    {
        private Repository _db;

        public ItemXref()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemVendorXref> GetVendorXrefSearchQuery()
        {
            return _db.GetQuery<tblICItemVendorXref>();
        }

        public object GetVendorXrefSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemVendorXref, bool>> predicate)
        {
            return GetVendorXrefSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetVendorXrefCount(Expression<Func<tblICItemVendorXref, bool>> predicate)
        {
            return GetVendorXrefSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemVendorXref> GetItemVendorXrefs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemVendorXref, bool>> predicate)
        {
            var query = GetVendorXrefSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemVendorXref>()
                .Include(p => p.vyuAPVendor)
                .Include(p => p.tblICItemUOM)
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemVendorXrefId == w.intItemVendorXrefId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemVendorXref(tblICItemVendorXref vendor)
        {
            _db.AddNew<tblICItemVendorXref>(vendor);
        }

        public void UpdateItemVendorXref(tblICItemVendorXref vendor)
        {
            _db.UpdateBatch<tblICItemVendorXref>(vendor);
        }

        public void DeleteItemVendorXref(tblICItemVendorXref vendor)
        {
            _db.Delete<tblICItemVendorXref>(vendor);
        }

        public IQueryable<tblICItemCustomerXref> GetCustomerXrefSearchQuery()
        {
            return _db.GetQuery<tblICItemCustomerXref>();
        }

        public object GetCustomerXrefSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemCustomerXref, bool>> predicate)
        {
            return GetCustomerXrefSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCustomerXrefCount(Expression<Func<tblICItemCustomerXref, bool>> predicate)
        {
            return GetCustomerXrefSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemCustomerXref> GetItemCustomerXrefs(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemCustomerXref, bool>> predicate)
        {
            var query = GetCustomerXrefSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemCustomerXref>()
                .Include(p => p.tblARCustomer)
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Where(w => query.Where(predicate).Any(a => a.intItemCustomerXrefId == w.intItemCustomerXrefId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemCustomerXref(tblICItemCustomerXref customer)
        {
            _db.AddNew<tblICItemCustomerXref>(customer);
        }

        public void UpdateItemCustomerXref(tblICItemCustomerXref customer)
        {
            _db.UpdateBatch<tblICItemCustomerXref>(customer);
        }

        public void DeleteItemCustomerXref(tblICItemCustomerXref customer)
        {
            _db.Delete<tblICItemCustomerXref>(customer);
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
