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
    public class ItemFactory : IDisposable
    {
        private Repository _db;

        public ItemFactory()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemFactory> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemFactory>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemFactory, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemFactory, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public int GetManufacturingCellCount(Expression<Func<tblICItemFactoryManufacturingCell, bool>> predicate)
        {
            return _db.GetQuery<tblICItemFactoryManufacturingCell>().Where(predicate).Count();
        }

        public IQueryable<tblICItemFactory> GetItemFactories(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemFactory, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemFactory>()
                .Include("tblICItemFactoryManufacturingCells.tblICManufacturingCell")
                .Include(p => p.tblSMCompanyLocation)
                .Where(w => query.Where(predicate).Any(a => a.intItemFactoryId == w.intItemFactoryId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public IQueryable<tblICItemFactoryManufacturingCell> GetItemFactoryManufacturingCells(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemFactoryManufacturingCell, bool>> predicate)
        {
            return _db.GetQuery<tblICItemFactoryManufacturingCell>()
                .Include(p => p.tblICManufacturingCell)
                .Where(predicate) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemFactory(tblICItemFactory factory)
        {
            _db.AddNew<tblICItemFactory>(factory);
        }

        public void UpdateItemFactory(tblICItemFactory factory)
        {
            _db.UpdateBatch<tblICItemFactory>(factory);
        }

        public void DeleteItemFactory(tblICItemFactory factory)
        {
            _db.Delete<tblICItemFactory>(factory);
        }

        public IQueryable<tblICItemOwner> GetOwnerSearchQuery()
        {
            return _db.GetQuery<tblICItemOwner>();
        }

        public object GetOwnerSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemOwner, bool>> predicate)
        {
            return GetOwnerSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetOwnerCount(Expression<Func<tblICItemOwner, bool>> predicate)
        {
            return GetOwnerSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemOwner> GetItemOwners(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemOwner, bool>> predicate)
        {
            var query = GetOwnerSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemOwner>()
                .Include(p => p.tblARCustomer)
                .Where(w => query.Where(predicate).Any(a => a.intItemOwnerId == w.intItemOwnerId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemOwner(tblICItemOwner owner)
        {
            _db.AddNew<tblICItemOwner>(owner);
        }

        public void UpdateItemOwner(tblICItemOwner owner)
        {
            _db.UpdateBatch<tblICItemOwner>(owner);
        }

        public void DeleteItemOwner(tblICItemOwner owner)
        {
            _db.Delete<tblICItemOwner>(owner);
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
