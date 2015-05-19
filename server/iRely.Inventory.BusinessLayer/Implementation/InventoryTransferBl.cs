using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
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
    public class InventoryTransferBl : BusinessLayer<tblICInventoryTransfer>, IInventoryTransferBl 
    {
        #region Constructor
        public InventoryTransferBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryTransfer>()
                .Include(p => p.FromLocation)
                .Include(p => p.ToLocation)
                .Include(p => p.tblICStatus)
                .Select(p => new TransferVM
                {
                    intInventoryTransferId = p.intInventoryTransferId,
                    strTransferNo = p.strTransferNo,
                    dtmTransferDate = p.dtmTransferDate,
                    strTransferType = p.strTransferType,
                    strDescription = p.strDescription,
                    intStatusId = p.intStatusId,
                    strStatus = p.tblICStatus.strStatus,
                    intFromLocationId = p.intFromLocationId,
                    strFromLocation = p.FromLocation.strLocationName,
                    intToLocationId = p.intToLocationId,
                    strToLocation = p.ToLocation.strLocationName,
                    ysnShipmentRequired = p.ysnShipmentRequired,
                    intSort = p.intSort,
                    ysnPosted = p.ysnPosted,
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryTransferId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override void Add(tblICInventoryTransfer entity)
        {
            entity.strTransferNo = Common.GetStartingNumber(Common.StartingNumber.InventoryTransfer);
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public SaveResult PostTransaction(Common.Posting_RequestModel Transfer, bool isRecap)
        {
            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                return result;
            }

            // Post the Adjustment transaction 
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                if (Transfer.isPost)
                {
                    db.PostInventoryTransfer(isRecap, Transfer.strTransactionId, iRely.Common.Security.GetUserId(), 1);
                }
                else
                {
                    db.UnPostInventoryTransfer(isRecap, Transfer.strTransactionId, iRely.Common.Security.GetUserId(), 1);
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
