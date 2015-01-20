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
    public class ItemContract : IDisposable
    {
        private Repository _db;

        public ItemContract()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemContract> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemContract>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemContract, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemContract, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemContract> GetItemContracts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemContract, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemContract>()
                .Include("tblICItemContractDocuments.tblICDocument")
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Include(p => p.tblSMCountry)
                .Where(w => query.Where(predicate).Any(a => a.intItemContractId == w.intItemContractId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemContract(tblICItemContract contract)
        {
            _db.AddNew<tblICItemContract>(contract);
        }

        public void UpdateItemContract(tblICItemContract contract)
        {
            _db.UpdateBatch<tblICItemContract>(contract);
        }

        public void DeleteItemContract(tblICItemContract contract)
        {
            _db.Delete<tblICItemContract>(contract);
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
