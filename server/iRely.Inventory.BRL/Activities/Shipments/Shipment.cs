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
    public class Shipment : IDisposable
    {
        private Repository _db;

        public Shipment()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<InventoryShipmentView> GetSearchQuery()
        {
            return _db.GetQuery<tblICInventoryShipment>().Select(p => new InventoryShipmentView { 
                intInventoryShipmentId = p.intInventoryShipmentId,
                strBOLNumber = p.strBOLNumber,
                intOrderType = p.intOrderType,
                strOrderType = (p.intOrderType == 1 ? "Sales Contract" : (p.intOrderType == 2 ? "Sales Order" : (p.intOrderType == 3 ? "Transfer Order" : ""))),
                dtmShipDate = p.dtmShipDate
            });
        }
        
        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<InventoryShipmentView, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<InventoryShipmentView, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICInventoryShipment> GetShipments(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<InventoryShipmentView, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICInventoryShipment>()
                .Include(p => p.ShipFromLocation)
                .Include(p => p.ShipToLocation)
                .Include("tblICInventoryShipmentItems.tblICInventoryShipmentItemLots.tblICLot")
                .Include("tblICInventoryShipmentItems.tblICItem")
                .Include("tblICInventoryShipmentItems.tblICUnitMeasure")
                .Include("tblICInventoryShipmentItems.WeightUnitMeasure")
                .Where(w => query.Where(predicate).Any(a => a.intInventoryShipmentId == w.intInventoryShipmentId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddShipment(tblICInventoryShipment shipment)
        {
            _db.AddNew<tblICInventoryShipment>(shipment);
        }

        public void UpdateShipment(tblICInventoryShipment shipment)
        {
            _db.UpdateBatch<tblICInventoryShipment>(shipment);
        }

        public void DeleteShipment(tblICInventoryShipment shipment)
        {
            _db.Delete<tblICInventoryShipment>(shipment);
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
