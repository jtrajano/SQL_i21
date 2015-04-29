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
    public class BuildAssembly : IDisposable
    {
        private Repository _db;

        public BuildAssembly()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<BuildAssemblyVM> GetSearchQuery()
        {
            return _db.GetQuery<tblICBuildAssembly>()
                .Include(p => p.tblICItem)
                .Include(p => p.tblICItemUOM.tblICUnitMeasure)
                .Include(p => p.tblSMCompanyLocation)
                .Include(p => p.tblSMCompanyLocationSubLocation)
                .Select(p => new BuildAssemblyVM
                {
                    intBuildAssemblyId = p.intBuildAssemblyId,
                    dtmBuildDate = p.dtmBuildDate,
                    intItemId = p.intItemId,
                    strItemNo = p.tblICItem.strItemNo,
                    strBuildNo = p.strBuildNo,
                    intLocationId = p.intLocationId,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    intSubLocationId = p.intSubLocationId,
                    strSubLocationName = p.tblSMCompanyLocationSubLocation.strSubLocationName,
                    intItemUOMId = p.intItemUOMId,
                    strItemUOM = p.tblICItemUOM.tblICUnitMeasure.strUnitMeasure,
                    strDescription = p.strDescription
                });
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<BuildAssemblyVM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<BuildAssemblyVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICBuildAssembly> GetBuildAssemblies(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<BuildAssemblyVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICBuildAssembly>()
                .Include("tblICBuildAssemblyDetails.tblICItem")
                .Include("tblICBuildAssemblyDetails.tblICItemUOM.tblICUnitMeasure")
                .Include("tblICBuildAssemblyDetails.tblSMCompanyLocationSubLocation")
                .Where(w => query.Where(predicate).Any(a => a.intBuildAssemblyId == w.intBuildAssemblyId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddBuildAssembly(tblICBuildAssembly build)
        {
            build.strBuildNo = Common.GetStartingNumber(Common.StartingNumber.BuildAssembly);
            //build.intCreatedUserId = iRely.Common.Security.GetUserId();
            //build.intEntityId = iRely.Common.Security.GetEntityId();
            _db.AddNew<tblICBuildAssembly>(build);
        }

        public void UpdateBuildAssembly(tblICBuildAssembly build)
        {
            _db.UpdateBatch<tblICBuildAssembly>(build);
        }

        public void DeleteBuildAssembly(tblICBuildAssembly build)
        {
            _db.Delete<tblICBuildAssembly>(build);
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
