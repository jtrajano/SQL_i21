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
            var salesOrderToUpdate = new List<int>();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    // Get the shipment id from records with Updated or New data. 
                    foreach (var shipment in _db.ContextManager.Set<tblICInventoryShipment>().Local)
                    {
                        if (shipment.intOrderType == 2)
                        {
                            if (!salesOrderToUpdate.Contains(shipment.intInventoryShipmentId))
                                salesOrderToUpdate.Add(shipment.intInventoryShipmentId);
                        }
                    }

                    // Get the shipment id from deleted records 
                    var deletedShipments = _db.ContextManager.ChangeTracker.Entries<tblICInventoryShipment>().Where(p => p.State == EntityState.Deleted).ToList();
                    foreach (var shipment in deletedShipments)
                    {
                        if (shipment.Entity.intOrderType == 2)
                        {
                            if (!salesOrderToUpdate.Contains(shipment.Entity.intInventoryShipmentId))
                                salesOrderToUpdate.Add(shipment.Entity.intInventoryShipmentId);
                        }
                    }

                    // Call the Sales Order SP to update the SO status 
                    foreach (var shipmentId in salesOrderToUpdate)
                    {
                        var idParameter = new SqlParameter("intShipmentId", shipmentId);
                        var openStatus = new SqlParameter("ysnOpenStatus", true);
                        _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdateSOStatusOnShipmentSave @intShipmentId, @ysnOpenStatus", idParameter, openStatus);
                    }

                    result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
                                        
                    // Update the stock reservation for the deleted shipments                    
                    foreach (var shipment in deletedShipments)
                    {
                        var idParameter = new SqlParameter("intTransactionId", shipment.Entity.intInventoryShipmentId);
                        _db.ContextManager.Database.ExecuteSqlCommand("uspICReserveStockForInventoryShipment @intTransactionId", idParameter);
                    }

                    
                    foreach (var shipment in _db.ContextManager.Set<tblICInventoryShipment>().Local)
                    {
                        
                        // Update the stock reservation for the latest shipment data. 
                        var intTransactionId = new SqlParameter("intTransactionId", shipment.intInventoryShipmentId);
                        _db.ContextManager.Database.ExecuteSqlCommand("uspICReserveStockForInventoryShipment @intTransactionId", intTransactionId);

                        // Update the sales order status using the latest shipment data
                        var intShipmentId = new SqlParameter("intShipmentId", shipment.intInventoryShipmentId);
                        _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdateSOStatusOnShipmentSave @intShipmentId", intShipmentId);
                    }

                    
                    foreach (var shipment in _db.ContextManager.Set<tblICInventoryShipment>().Local)
                    {
                        
                        

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
