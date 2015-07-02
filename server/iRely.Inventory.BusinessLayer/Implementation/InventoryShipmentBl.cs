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
                .Include(p => p.tblARCustomer)
                .Select(p => new ShipmentVM
                {
                    intInventoryShipmentId = p.intInventoryShipmentId,
                    strShipmentNumber = p.strShipmentNumber,
                    intOrderType = p.intOrderType,
                    strOrderType = (p.intOrderType == 1 ? "Sales Contract" : (p.intOrderType == 2 ? "Sales Order" : (p.intOrderType == 3 ? "Transfer Order" : (p.intOrderType == 4 ? "Direct" : "")))),
                    dtmShipDate = p.dtmShipDate,
                    strCustomerId = p.tblARCustomer.strCustomerNumber,
                    strCustomerName = p.tblARCustomer.strCustomerName,
                    ysnPosted = p.ysnPosted
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override async Task<BusinessResult<tblICInventoryShipment>> SaveAsync(bool continueOnConflict)
        {
            SaveResult result = new SaveResult();
            var soList = new List<int>();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    foreach (var shipment in _db.ContextManager.Set<tblICInventoryShipment>().Local)
                    {
                        if (shipment.intOrderType == 2)
                        {
                            if (!soList.Contains(shipment.intInventoryShipmentId))
                                soList.Add(shipment.intInventoryShipmentId);
                        }
                    }
                    var changedReceipts = _db.ContextManager.ChangeTracker.Entries<tblICInventoryShipment>().Where(p => p.State == EntityState.Deleted).ToList();
                    foreach (var shipment in changedReceipts)
                    {
                        if (shipment.Entity.intOrderType == 2)
                        {
                            if (!soList.Contains(shipment.Entity.intInventoryShipmentId))
                                soList.Add(shipment.Entity.intInventoryShipmentId);
                        }
                    }

                    result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);

                    foreach (var shipmentId in soList)
                    {
                        var idParameter = new SqlParameter("intShipmentId", shipmentId);
                        _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdateSOStatusOnShipmentSave @intShipmentId", idParameter);
                    }

                    transaction.Commit();

                    if (result.HasError)
                    {
                        throw result.BaseException;
                    }
                }
                catch (Exception ex)
                {
                    result.BaseException = ex;
                    result.Exception = new ServerException(ex);
                    result.HasError = true;
                    transaction.Rollback();
                }
            }

            return new BusinessResult<tblICInventoryShipment>()
            {
                success = !result.HasError,
                message = new MessageResult()
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            };
        }

        public SaveResult ProcessInvoice(int shipmentId, out int? newInvoice)
        {
            SaveResult saveResult = new SaveResult();
            int? newInvoiceId = null;

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("ShipmentId", shipmentId);
                    var userId = new SqlParameter("@UserId", iRely.Common.Security.GetEntityId());
                    var outParam = new SqlParameter("@NewInvoiceId", newInvoiceId);
                    outParam.Direction = System.Data.ParameterDirection.Output;
                    outParam.DbType = System.Data.DbType.Int32;
                    outParam.SqlDbType = System.Data.SqlDbType.Int;
                    _db.ContextManager.Database.ExecuteSqlCommand("uspARCreateInvoiceFromShipment @ShipmentId, @UserId, @NewInvoiceId OUTPUT", idParameter, userId, outParam);
                    newInvoiceId = (int)outParam.Value;
                    saveResult = _db.Save(false);
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    saveResult.BaseException = ex;
                    saveResult.Exception = new ServerException(ex);
                    saveResult.HasError = true;
                    //transaction.Rollback();
                }
            }
            newInvoice = newInvoiceId;
            return saveResult;
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
