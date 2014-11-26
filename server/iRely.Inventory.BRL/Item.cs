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
                .Include(p => p.tblICBrand)
                .Include(p => p.tblICManufacturer)
                .Select(p => new ItemVM
                {
                    intItemId = p.intItemId,
                    strItemNo = p.strItemNo,
                    strType = p.strType,
                    strDescription = p.strDescription,
                    strStatus = p.strStatus,
                    strModelNo = p.strModelNo,
                    strLotTracking = p.strLotTracking,
                    strBrand = p.tblICBrand.strBrandCode,
                    strManufacturer = p.tblICManufacturer.strManufacturer,
                    strTracking = p.strInventoryTracking
                });
        }

        public IEnumerable<tblICItem> GetEmpty()
        {
            return _db.GetQuery<tblICItem>()
                    .Include("tblICItemUOMs.tblICUnitMeasure")
                    .Include("tblICItemLocations.tblSMCompanyLocation")
                    .Include("tblICItemLocations.vyuAPVendor")
                    .Include("tblICItemLocations.tblICCategory")
                    .Include("tblICItemLocations.tblICUnitMeasure")
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
                    .Include("tblICItemPricings.tblSMCompanyLocation")
                    .Include("tblICItemPricingLevels.tblSMCompanyLocation")
                    .Include("tblICItemPricingLevels.tblICUnitMeasure")
                    .Include("tblICItemSpecialPricings.tblSMCompanyLocation")
                    .Include("tblICItemSpecialPricings.tblICUnitMeasure")
                    .Include("tblICItemStocks.tblSMCompanyLocation")
                    .Include("tblICItemStocks.tblICUnitMeasure")
                    .Include("tblICItemStocks.tblICCountGroup")
                    .Include("tblICItemAccounts.tblGLAccount")
                    .Include("tblICItemAccounts.ProfitCenter")
                    .Include("tblICItemAssemblies.AssemblyItem")
                    .Include("tblICItemAssemblies.tblICUnitMeasure")
                    .Include("tblICItemBundles.BundleItem")
                    .Include("tblICItemBundles.tblICUnitMeasure")
                    .Include("tblICItemKits.tblICItemKitDetails.tblICItem")
                    .Include("tblICItemKits.tblICItemKitDetails.tblICUnitMeasure")
                    .Include("tblICItemNotes.tblSMCompanyLocation")
                    .Include("tblICItemFactories.tblSMCompanyLocation")
                    .Include("tblICItemFactories.tblICItemFactoryManufacturingCells.tblICManufacturingCell")
                    .Include("tblICItemOwners.tblARCustomer")
                    .Take(0).ToList();
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
            var finalQuery = _db.GetQuery<tblICItem>()
                    .Include("tblICItemUOMs.tblICUnitMeasure")
                    .Include("tblICItemLocations.tblSMCompanyLocation")
                    .Include("tblICItemLocations.vyuAPVendor")
                    .Include("tblICItemLocations.tblICCategory")
                    .Include("tblICItemLocations.tblICUnitMeasure")
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
                    .Include("tblICItemPricings.tblSMCompanyLocation")
                    .Include("tblICItemPricingLevels.tblSMCompanyLocation")
                    .Include("tblICItemPricingLevels.tblICUnitMeasure")
                    .Include("tblICItemSpecialPricings.tblSMCompanyLocation")
                    .Include("tblICItemSpecialPricings.tblICUnitMeasure")
                    .Include("tblICItemStocks.tblSMCompanyLocation")
                    .Include("tblICItemStocks.tblICUnitMeasure")
                    .Include("tblICItemStocks.tblICCountGroup")
                    .Include("tblICItemAccounts.tblGLAccount")
                    .Include("tblICItemAccounts.ProfitCenter")
                    .Include("tblICItemAssemblies.AssemblyItem")
                    .Include("tblICItemAssemblies.tblICUnitMeasure")
                    .Include("tblICItemBundles.BundleItem")
                    .Include("tblICItemBundles.tblICUnitMeasure")
                    .Include("tblICItemKits.tblICItemKitDetails.tblICItem")
                    .Include("tblICItemKits.tblICItemKitDetails.tblICUnitMeasure")
                    .Include("tblICItemNotes.tblSMCompanyLocation")
                    .Include("tblICItemFactories.tblSMCompanyLocation")
                    .Include("tblICItemFactories.tblICItemFactoryManufacturingCells.tblICManufacturingCell")
                    .Include("tblICItemOwners.tblARCustomer")
                    .Where(w => query.Where(predicate).Any(a => a.intItemId == w.intItemId)) //Filter the Main DataSource Based on Search Query
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit)
                    .AsNoTracking();
            return finalQuery;
        }

        public object GetCompactItems(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<ItemVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItem>()
                    .Where(w => query.Where(predicate).Any(a => a.intItemId == w.intItemId)) //Filter the Main DataSource Based on Search Query
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit)
                    .AsNoTracking()
                    .Select(p => new
                    {
                        intItemId = p.intItemId,
                        strItemNo = p.strItemNo,
                        strType = p.strType,
                        strDescription = p.strDescription,
                        strStatus = p.strStatus,
                        strModelNo = p.strModelNo,
                        strLotTracking = p.strLotTracking
                    }).ToList();
        }

        public object GetItemStocks(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<vyuICGetItemStock, bool>> predicate)
        {
            return _db.GetQuery<vyuICGetItemStock>()
                    .Where(predicate)
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit)
                    .AsNoTracking()
                    .ToList();
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
