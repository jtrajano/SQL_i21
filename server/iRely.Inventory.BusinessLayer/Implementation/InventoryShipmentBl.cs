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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
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
                        // Call this sp before the _db.SaveAsync because uspICBeforeShipmentDelete is not reading it from the log table. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICBeforeShipmentDelete @intShipmentId",
                            new SqlParameter("intShipmentId", shipment.Entity.intInventoryShipmentId)
                        );
                    }

                    // Save the data. 
                    result = await _db.SaveAsync(true).ConfigureAwait(false);

                    // Process the deleted records. 
                    foreach (var shipment in deletedShipments)
                    {                        
                        // This will also update contract from deleted shipment records. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
                                "uspICInventoryShipmentAfterSave @ShipmentId, @ForDelete, @UserId",
                                new SqlParameter("ShipmentId", shipment.Entity.intInventoryShipmentId),
                                new SqlParameter("ForDelete", true),
                                new SqlParameter("UserId", DefaultUserId)
                        );
                    }
                                        
                    // Process the new or updated records. 
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
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            entity.strShipmentNumber = db.GetStartingNumber((int)Common.StartingNumber.InventoryShipment, entity.intShipFromLocationId);
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public Common.GLPostResult PostTransaction(Common.Posting_RequestModel shipment, bool isRecap)
        {
            var glPostResult = new Common.GLPostResult();
            glPostResult.Exception = new ServerException();

            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                glPostResult.BaseException = result.BaseException;
                glPostResult.Exception = result.Exception;
                glPostResult.HasError = result.HasError;
                glPostResult.RowsAffected = result.RowsAffected;
                //glPostResult.strBatchId = null; 

                return glPostResult;
            }

            // Post the receipt transaction 
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                string strBatchId;
                if (shipment.isPost)
                {
                    strBatchId = db.PostInventoryShipment(isRecap, shipment.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    strBatchId = db.UnPostInventoryShipment(isRecap, shipment.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                glPostResult.HasError = false;
                glPostResult.strBatchId = strBatchId;
            }
            catch (Exception ex)
            {
                glPostResult.BaseException = ex;
                glPostResult.HasError = true;
                glPostResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return glPostResult;
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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetAddOrders(GetParameter param, int CustomerId, string OrderType, string SourceType)
        {
            if (OrderType == "Sales Contract" && SourceType == "None")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesContract>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
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
                    total = await query.CountAsync(),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else if (OrderType == "Sales Order" && SourceType == "None")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesOrder>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else {
                // return an empty search result. 
                return new SearchResult()
                {
                    data = null,
                    total = 0,
                    summaryData = null
                };
            }
            //else
            //{
            //    var query = _db.GetQuery<vyuICGetShipmentAddOrder>()
            //           .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
            //           .Filter(param, true);
            //    var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

            //    return new SearchResult()
            //    {
            //        data = data.AsQueryable(),
            //        total = await query.CountAsync(),
            //        summaryData = await query.ToAggregateAsync(param.aggregates)
            //    };

            //}
        }

        public async Task<SearchResult> SearchShipmentInvoice(GetParameter param)
        {
            var query = _db.GetQuery<vyuICShipmentInvoice>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryShipmentItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
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

        public async Task<SearchResult> SearchCustomerCurrency(GetParameter param, int? entityId)
        {
            var query = _db.GetQuery<vyuICGetCustomerCurrency>()
                .Where(p => p.intEntityId == entityId);

            var data = await query.ExecuteProjection(param, "intEntityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
        public SaveResult UpdateShipmentInvoice()
        {
            SaveResult saveResult = new SaveResult();

            // Populate the Shipment Invoice 
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.PopulateShipmentInvoice();
                saveResult.HasError = false;
            }
            catch (Exception ex)
            {
                saveResult.BaseException = ex;
                saveResult.HasError = true;
                saveResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return saveResult;
        }
    }
}
