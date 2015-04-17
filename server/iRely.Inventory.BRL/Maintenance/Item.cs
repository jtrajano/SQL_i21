﻿using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
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

        public int GetAssemblyCount(Expression<Func<ItemVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Where(p => p.strType == "Assembly/Blend" && p.strLotTracking == "No").Count();
        }

        public IQueryable<tblICItem> GetItems(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<ItemVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            var finalQuery = _db.GetQuery<tblICItem>()                
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
                    .Include(p => p.tblICCommodity)
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
                        strLotTracking = p.strLotTracking,
                        intCommodityId = p.intCommodityId,
                        strCommodityId = p.tblICCommodity.strCommodityCode
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

        public object GetItemStockDetails(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<vyuICGetItemStock, bool>> predicate)
        {
            var query = _db.GetQuery<vyuICGetItemStock>()
                .Include(p => p.tblICItemAccounts)
                .Include(p => p.tblICItemPricings)
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();

            var data = query.ToList();
            
            return data;
        }

        public IQueryable<tblICItem> GetAssemblyItems(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<ItemVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            var finalQuery = _db.GetQuery<tblICItem>()
                    .Include("tblICItemAssemblies.tblICItem")
                    .Include("tblICItemAssemblies.tblICItemUOM.tblICUnitMeasure")
                    .Where(w => query.Where(predicate).Any(a => a.intItemId == w.intItemId)) //Filter the Main DataSource Based on Search Query
                    .Where(p => p.strType == "Assembly/Blend" && p.strLotTracking == "No")
                    .OrderBySelector(sortSelector)
                    .Skip(start)
                    .Take(limit);
            return finalQuery;
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

        public int? DuplicateItem(int intItemId)
        {
            int? newItemId = null;

            using (SqlConnection conn = new SqlConnection(_db.ContextManager.Database.Connection.ConnectionString))
            {
                conn.Open();
                using (SqlCommand command = new SqlCommand("uspICDuplicateItem", conn))
                {
                    command.Parameters.Add(new SqlParameter("@ItemId", intItemId));
                    var outParam = new SqlParameter("@NewItemId", newItemId);
                    outParam.Direction = System.Data.ParameterDirection.Output;
                    outParam.DbType = System.Data.DbType.Int32;
                    outParam.SqlDbType = System.Data.SqlDbType.Int;
                    command.Parameters.Add(outParam);
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                    newItemId = (int)outParam.Value;
                }
                conn.Close();
            }
           
            return newItemId;
        }
        
        public void Dispose()
        {
            _db.Dispose();
        }
    }
}
