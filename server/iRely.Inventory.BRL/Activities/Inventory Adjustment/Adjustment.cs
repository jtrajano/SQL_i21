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
    public partial class Adjustment : IDisposable
    {
        private Repository _db;

        public Adjustment()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<AdjustmentVM> GetSearchQuery()
        {
            return _db.GetQuery<tblICInventoryAdjustment>()
                .Include(p => p.tblSMCompanyLocation)
                .Select(p => new AdjustmentVM
                {
                    intInventoryAdjustmentId = p.intInventoryAdjustmentId,
                    intLocationId = p.intLocationId,
                    dtmAdjustmentDate = p.dtmAdjustmentDate,
                    intAdjustmentType = p.intAdjustmentType,
                    strAdjustmentNo = p.strAdjustmentNo,
                    strDescription = p.strDescription,
                    intSort = p.intSort,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    ysnPosted = p.ysnPosted
                });
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<AdjustmentVM, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<AdjustmentVM, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICInventoryAdjustment> GetAdjustments(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<AdjustmentVM, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICInventoryAdjustment>()
                .Include("tblICInventoryAdjustmentDetails.tblSMCompanyLocationSubLocation")
                .Include("tblICInventoryAdjustmentDetails.tblICStorageLocation")
                .Include("tblICInventoryAdjustmentDetails.Item")
                .Include("tblICInventoryAdjustmentDetails.NewItem")
                .Include("tblICInventoryAdjustmentDetails.Lot")
                .Include("tblICInventoryAdjustmentDetails.NewLot")
                .Include("tblICInventoryAdjustmentDetails.ItemUOM.tblICUnitMeasure")
                .Include("tblICInventoryAdjustmentDetails.NewItemUOM.tblICUnitMeasure")
                .Include("tblICInventoryAdjustmentDetails.WeightUOM.tblICUnitMeasure")
                .Include("tblICInventoryAdjustmentDetails.NewWeightUOM.tblICUnitMeasure")
                .Include("tblICInventoryAdjustmentDetails.OldLotStatus")
                .Include("tblICInventoryAdjustmentDetails.NewLotStatus")
                .Include("tblICInventoryAdjustmentDetails.NewLocation")
                .Include("tblICInventoryAdjustmentDetails.NewSubLocation")
                .Include("tblICInventoryAdjustmentDetails.NewStorageLocation")
                
                .Include(p => p.tblICInventoryAdjustmentNotes)
                .Where(w => query.Where(predicate).Any(a => a.intInventoryAdjustmentId == w.intInventoryAdjustmentId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddAdjustment(tblICInventoryAdjustment adjustment)
        {
            adjustment.strAdjustmentNo = Common.GetStartingNumber(Common.StartingNumber.InventoryAdjustment);
            //adjustment.intCreatedUserId = iRely.Common.Security.GetUserId();
            //adjustment.intEntityId = iRely.Common.Security.GetEntityId();
            _db.AddNew<tblICInventoryAdjustment>(adjustment);
        }

        public void UpdateAdjustment(tblICInventoryAdjustment adjustment)
        {
            _db.UpdateBatch<tblICInventoryAdjustment>(adjustment);
        }

        public void DeleteAdjustment(tblICInventoryAdjustment adjustment)
        {
            _db.Delete<tblICInventoryAdjustment>(adjustment);
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
