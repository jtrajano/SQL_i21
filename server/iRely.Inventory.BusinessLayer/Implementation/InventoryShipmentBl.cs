using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryShipmentBl : BusinessLayer<tblICInventoryShipment>, IInventoryShipmentBl 
    {
        #region Constructor
        public InventoryShipmentBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryShipment>()
                .Select(p => new InventoryShipmentView
                {
                    intInventoryShipmentId = p.intInventoryShipmentId,
                    strShipmentNumber = p.strShipmentNumber,
                    strBOLNumber = p.strBOLNumber,
                    intOrderType = p.intOrderType,
                    strOrderType = (p.intOrderType == 1 ? "Sales Contract" : (p.intOrderType == 2 ? "Sales Order" : (p.intOrderType == 3 ? "Transfer Order" : ""))),
                    dtmShipDate = p.dtmShipDate
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override void Add(tblICInventoryShipment entity)
        {
            entity.strShipmentNumber = Common.GetStartingNumber(Common.StartingNumber.InventoryShipment);
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public SaveResult PostTransaction(Common.Posting_RequestModel shipment, bool isRecap)
        {
            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                return result;
            }

            // Post the receipt transaction 
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                if (shipment.isPost)
                {
                    db.PostInventoryShipment(isRecap, shipment.strTransactionId, iRely.Common.Security.GetUserId(), iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnPostInventoryShipment(isRecap, shipment.strTransactionId, iRely.Common.Security.GetUserId(), iRely.Common.Security.GetEntityId());
                }
                postResult.HasError = false;
            }
            catch (Exception ex)
            {
                postResult.BaseException = ex;
                postResult.HasError = true;
                postResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return postResult;
        }
    }
}
