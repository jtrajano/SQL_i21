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
            _db.ContextManager.Database.CommandTimeout = 180000;
        }
        #endregion

        public static int DefaultUserId;

        public void SetUser(int UserId)
        {
            DefaultUserId = UserId;
        }

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryShipment>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strshipmentnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryShipmentId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strshipmentnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryShipmentId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

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

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {                  
                    // Get the shipment id from deleted records 
                    var deletedShipments = _db.ContextManager.ChangeTracker.Entries<tblICInventoryShipment>().Where(p => p.State == EntityState.Deleted).ToList();

                    // Log the original data. 
                    foreach (var shipment in _db.ContextManager.Set<tblICInventoryShipment>().Local)
                    {
                        // Log the original detail records. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICLogTransactionDetail @TransactionType, @TransactionId",
                            new SqlParameter("TransactionType", 2),
                            new SqlParameter("TransactionId", shipment.intInventoryShipmentId)
                        );
                    }

                    // Log the original data from the deleted shipments
                    foreach (var shipment in deletedShipments)
                    {
                        // Log the original detail records. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICLogTransactionDetail @TransactionType, @TransactionId",
                            new SqlParameter("TransactionType", 2),
                            new SqlParameter("TransactionId", shipment.Entity.intInventoryShipmentId)
                        );

                        // Update the SO or Scale status from deleted shipment records.
                        // Usually, deleted records will "open" the status of the SO or Scale Ticket. 
                        // Call this sp before the _db.SaveAsync because uspICUpdateStatusOnShipmentSave is not reading it from the log table. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICUpdateStatusOnShipmentSave @intShipmentId, @ysnOpenStatus",
                            new SqlParameter("intShipmentId", shipment.Entity.intInventoryShipmentId),
                             new SqlParameter("ysnOpenStatus", true)
                        );
                    }

                    // Save the data. 
                    result = await _db.SaveAsync(true).ConfigureAwait(false);

                    // Process the deleted records. 
                    foreach (var shipment in deletedShipments)
                    {
                        // Update the stock reservation for the deleted shipments                    
                        //_db.ContextManager.Database.ExecuteSqlCommand(
                        //    "uspICReserveStockForInventoryShipment @intTransactionId",
                        //    new SqlParameter("intTransactionId", shipment.Entity.intInventoryShipmentId)
                        //);
                        
                        // This will also update contract from deleted shipment records. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
                                "uspICInventoryShipmentAfterSave @ShipmentId, @ForDelete, @UserId",
                                new SqlParameter("ShipmentId", shipment.Entity.intInventoryShipmentId),
                                new SqlParameter("ForDelete", true),
                                new SqlParameter("UserId", DefaultUserId)
                        );
                    }
                                        
                    // Process the newly saved record. 
                    foreach (var shipment in _db.ContextManager.Set<tblICInventoryShipment>().Local)
                    {
                        var intShipmentId = new SqlParameter("intShipmentId", shipment.intInventoryShipmentId);
                        
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICUpdateStatusOnShipmentSave @intShipmentId", 
                            intShipmentId
                        );

                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICInventoryShipmentAfterSave @ShipmentId, @ForDelete, @UserId",
                            new SqlParameter("ShipmentId", shipment.intInventoryShipmentId), 
                            new SqlParameter("ForDelete", false), 
                            new SqlParameter("UserId", DefaultUserId)
                        );
                    }

                    if (result.HasError)
                    {
                        throw result.BaseException;
                    }
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    result.BaseException = ex;
                    result.Exception = new ServerException(ex);
                    result.HasError = true;
                    //transaction.Rollback();
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
                    db.PostInventoryShipment(isRecap, shipment.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnPostInventoryShipment(isRecap, shipment.strTransactionId, iRely.Common.Security.GetEntityId());
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

        public async Task<SearchResult> SearchShipmentItems(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryShipmentItem>()
                .Filter(param, true);
            
            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strshipmentnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryShipmentId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strshipmentnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryShipmentId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> SearchShipmentItemLots(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryShipmentItemLot>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strshipmentnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryShipmentId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strshipmentnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryShipmentId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetAddOrders(GetParameter param, int CustomerId, string OrderType, string SourceType)
        {
            if (OrderType == "Sales Order" && SourceType == "None")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesOrder>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync()
                };
            }
            else if (OrderType == "Sales Contract" && SourceType == "None")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesContract>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync()
                };
            }
            else if (OrderType == "Sales Contract" && SourceType == "Pick Lot")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesContractPickLot>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync()
                };
            }
            else
            {
                var query = _db.GetQuery<vyuICGetShipmentAddOrder>()
                       .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                       .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync()
                };

            }
        }

        public SaveResult CalculateCharges(int shipmentId)
        {
            SaveResult saveResult = new SaveResult();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("@intInventoryShipmentId", shipmentId);
                    _db.ContextManager.Database.ExecuteSqlCommand("uspICCalculateShipmentOtherCharges @intInventoryShipmentId", idParameter);
                    saveResult = _db.Save(false);
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    saveResult.BaseException = ex;
                    saveResult.Exception = new ServerException(ex);
                    saveResult.HasError = true;
                }
            }
            return saveResult;
        }
    }
}
