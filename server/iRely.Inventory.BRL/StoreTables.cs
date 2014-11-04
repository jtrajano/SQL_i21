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
    
    public class Store : IDisposable
    {
        private Repository _db;

        public Store()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblSTStore> GetSearchQuery()
        {
            return _db.GetQuery<tblSTStore>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblSTStore, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblSTStore, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblSTStore> GetStores(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblSTStore, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblSTStore>()
                .Where(w => query.Where(predicate).Any(a => a.intStoreId == w.intStoreId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddStore(tblSTStore store)
        {
            _db.AddNew<tblSTStore>(store);
        }

        public void UpdateStore(tblSTStore store)
        {
            _db.UpdateBatch<tblSTStore>(store);
        }

        public void DeleteStore(tblSTStore store)
        {
            _db.Delete<tblSTStore>(store);
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

    public class PaidOut : IDisposable
    {
        private Repository _db;

        public PaidOut()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblSTPaidOut> GetSearchQuery()
        {
            return _db.GetQuery<tblSTPaidOut>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblSTPaidOut, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblSTPaidOut, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblSTPaidOut> GetPaidOuts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblSTPaidOut, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblSTPaidOut>()
                .Where(w => query.Where(predicate).Any(a => a.intPaidOutId == w.intPaidOutId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddPaidOut(tblSTPaidOut paidout)
        {
            _db.AddNew<tblSTPaidOut>(paidout);
        }

        public void UpdatePaidOut(tblSTPaidOut paidout)
        {
            _db.UpdateBatch<tblSTPaidOut>(paidout);
        }

        public void DeletePaidOut(tblSTPaidOut paidout)
        {
            _db.Delete<tblSTPaidOut>(paidout);
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

    public class SubcategoryClass : IDisposable
    {
        private Repository _db;

        public SubcategoryClass()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblSTSubcategoryClass> GetSearchQuery()
        {
            return _db.GetQuery<tblSTSubcategoryClass>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblSTSubcategoryClass, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblSTSubcategoryClass, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblSTSubcategoryClass> GetSubcategoryClasss(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblSTSubcategoryClass, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblSTSubcategoryClass>()
                .Where(w => query.Where(predicate).Any(a => a.intClassId == w.intClassId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddSubcategoryClass(tblSTSubcategoryClass subcategoryclass)
        {
            _db.AddNew<tblSTSubcategoryClass>(subcategoryclass);
        }

        public void UpdateSubcategoryClass(tblSTSubcategoryClass subcategoryclass)
        {
            _db.UpdateBatch<tblSTSubcategoryClass>(subcategoryclass);
        }

        public void DeleteSubcategoryClass(tblSTSubcategoryClass subcategoryclass)
        {
            _db.Delete<tblSTSubcategoryClass>(subcategoryclass);
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

    public class SubcategoryFamily : IDisposable
    {
        private Repository _db;

        public SubcategoryFamily()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblSTSubcategoryFamily> GetSearchQuery()
        {
            return _db.GetQuery<tblSTSubcategoryFamily>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblSTSubcategoryFamily, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblSTSubcategoryFamily, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblSTSubcategoryFamily> GetSubcategoryFamilys(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblSTSubcategoryFamily, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblSTSubcategoryFamily>()
                .Where(w => query.Where(predicate).Any(a => a.intFamilyId == w.intFamilyId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddSubcategoryFamily(tblSTSubcategoryFamily family)
        {
            _db.AddNew<tblSTSubcategoryFamily>(family);
        }

        public void UpdateSubcategoryFamily(tblSTSubcategoryFamily family)
        {
            _db.UpdateBatch<tblSTSubcategoryFamily>(family);
        }

        public void DeleteSubcategoryFamily(tblSTSubcategoryFamily family)
        {
            _db.Delete<tblSTSubcategoryFamily>(family);
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

    public class SubcategoryRegProd : IDisposable
    {
        private Repository _db;

        public SubcategoryRegProd()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblSTSubcategoryRegProd> GetSearchQuery()
        {
            return _db.GetQuery<tblSTSubcategoryRegProd>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblSTSubcategoryRegProd, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblSTSubcategoryRegProd, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblSTSubcategoryRegProd> GetSubcategoryRegProds(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblSTSubcategoryRegProd, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblSTSubcategoryRegProd>()
                .Where(w => query.Where(predicate).Any(a => a.intRegProdId == w.intRegProdId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddSubcategoryRegProd(tblSTSubcategoryRegProd product)
        {
            _db.AddNew<tblSTSubcategoryRegProd>(product);
        }

        public void UpdateSubcategoryRegProd(tblSTSubcategoryRegProd product)
        {
            _db.UpdateBatch<tblSTSubcategoryRegProd>(product);
        }

        public void DeleteSubcategoryRegProd(tblSTSubcategoryRegProd product)
        {
            _db.Delete<tblSTSubcategoryRegProd>(product);
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
