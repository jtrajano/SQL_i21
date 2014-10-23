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
    public class Item : IDisposable
    {
        private Repository _db;

        public Item()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<ItemVM> GetSearchQuery()
        {
            return _db.GetQuery<tblICItem>()
                .Select(p => new ItemVM { 
                    intItemId = p.intItemId,
                    strItemNo = p.strItemNo,
                    strType = p.strType,
                    strDescription = p.strDescription,
                    intManufacturerId = p.intManufacturerId,
                    intBrandId = p.intBrandId,
                    strStatus = p.strStatus,
                    strModelNo = p.strModelNo,
                    intTrackingId = p.intTrackingId,
                    strLotTracking = p.strLotTracking
                });
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<ItemVM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<ItemVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItem> GetItems(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<ItemVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItem>()
                    .Include("tblICItemUOMs.tblICUnitMeasure")
                    .Include(p => p.tblICItemLocations)
                    .Include("tblICItemPOSCategories.tblICCategory")
                    .Include(p => p.tblICItemPOSSLAs)
                    .Include(p => p.tblICItemManufacturingUOMs)
                    .Include("tblICItemUPCs.tblICUnitMeasure")
                    .Include("tblICItemCustomerXrefs.tblSMCompanyLocation")
                    .Include("tblICItemCustomerXrefs.tblARCustomer")
                    .Include("tblICItemVendorXrefs.tblSMCompanyLocation")
                    .Include("tblICItemVendorXrefs.vyuAPVendor")
                    .Include("tblICItemVendorXrefs.tblICUnitMeasure")
                    .Include("tblICItemContracts.tblSMCompanyLocation")
                    .Include("tblICItemContracts.tblSMCountry")
                    
                    .Include("tblICItemContracts.tblICItemContractDocuments.tblICDocument")

                    .Include("tblICItemCertifications.tblICCertification")
                    .Include(p => p.tblICItemPricings)
                    .Include(p => p.tblICItemPricingLevels)
                    .Include(p => p.tblICItemSpecialPricings)
                    .Include("tblICItemStocks.tblSMCompanyLocation")
                    .Include("tblICItemStocks.tblICUnitMeasure")
                    .Include("tblICItemStocks.tblICCountGroup")
                    .Include("tblICItemAccounts.tblGLAccount")
                    .Include("tblICItemAccounts.ProfitCenter")
                    .Include("tblICItemAccounts.tblSMCompanyLocation")
                    .Include("tblICItemNotes.tblSMCompanyLocation")
                    .Where(w => query.Where(predicate).Any(a => a.intItemId == w.intItemId)) //Filter the Main DataSource Based on Search Query
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit)
                    .AsNoTracking();
        }

        public void AddItem(tblICItem item)
        {
            _db.AddNew<tblICItem>(item);
        }

        public void UpdateItem(tblICItem item)
        {
            _db.UpdateBatch<tblICItem>(item);
        }

        public void DeleteItem(tblICItem item)
        {
            _db.Delete<tblICItem>(item);
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
