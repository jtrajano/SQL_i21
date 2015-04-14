﻿using System;
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
    public class Commodity : IDisposable
    {
        private Repository _db;

        public Commodity()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<CommodityVM> GetSearchQuery()
        {
            return _db.GetQuery<tblICCommodity>()
                .Select(p => new CommodityVM { 
                    intCommodityId = p.intCommodityId,
                    strCommodityCode = p.strCommodityCode,
                    strDescription = p.strDescription
                });
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<CommodityVM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<CommodityVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICCommodity> GetCommodities(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<CommodityVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCommodity>()
                .Include("tblICCommodityUnitMeasures.tblICUnitMeasure")
                .Include("tblICCommodityAccounts.tblGLAccount")
                .Include("tblICCommodityAccounts.tblGLAccountCategory")
                .Include("tblICCommodityAccounts.tblSMCompanyLocation")
                .Include(p => p.tblICCommodityClassVariants)
                .Include(p => p.tblICCommodityGrades)
                .Include(p => p.tblICCommodityOrigins)
                .Include(p => p.tblICCommodityProductLines)
                .Include(p => p.tblICCommodityProductTypes)
                .Include(p => p.tblICCommodityRegions)
                .Include(p => p.tblICCommoditySeasons)
                .Include(p => p.tblICCommodityGroups)
                .Where(w => query.Where(predicate).Any(a => a.intCommodityId == w.intCommodityId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public object GetCompactCommodities(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<CommodityVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICCommodity>()
                .Include("tblICCommodityUnitMeasures.tblICUnitMeasure")
                .Where(w => query.Where(predicate).Any(a => a.intCommodityId == w.intCommodityId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddCommodity(tblICCommodity commodity)
        {
            _db.AddNew<tblICCommodity>(commodity);
        }

        public void UpdateCommodity(tblICCommodity commodity)
        {
            _db.UpdateBatch<tblICCommodity>(commodity);
        }

        public void DeleteCommodity(tblICCommodity commodity)
        {
            _db.Delete<tblICCommodity>(commodity);
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
