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
        public InventoryShipmentBl(IInventoryRepository db) : base(db)
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

            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
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
                        // Clear the receipt per charge records. Let the Receipt posting re-create it. 
                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICDeleteChargePerItemOnShipmentSave @intShipmentNo",
                            new SqlParameter("intShipmentNo", shipment.intInventoryShipmentId)
                        );

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
                    result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);

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

        public async Task<int?> ProcessShipmentToInvoice(int shipmentId)
        {
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            return await db.ProcessShipmentToInvoice(shipmentId);
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

            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
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

            var data = await query.ExecuteProjection(param, "intInventoryShipmentId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
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
                var data = await query.ExecuteProjection(param, "intLineNo").ToListAsync(param.cancellationToken);

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else if (OrderType == "Sales Contract" && SourceType == "Pick Lot")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesContractPickLot>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intLineNo").ToListAsync(param.cancellationToken);

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else if (OrderType == "Sales Order" && SourceType == "None")
            {
                var query = _db.GetQuery<vyuICGetShipmentAddSalesOrder>()
                    .Where(p => p.intEntityCustomerId == CustomerId && p.strOrderType == OrderType && p.strSourceType == SourceType)
                    .Filter(param, true);
                var data = await query.ExecuteProjection(param, "intLineNo").ToListAsync(param.cancellationToken);

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
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
            var data = await query.ExecuteProjection(param, "intInventoryShipmentItemId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
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

            var data = await query.ExecuteProjection(param, "intEntityId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken)
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

        public async Task<GetObjectResult> GetShipmentCharges(GetParameter param)
        {
            var key = Methods.GetPrimaryKey<vyuICGetInventoryShipmentCharge>(_db.ContextManager);
            try
            {
                var query = _db.GetQuery<tblICInventoryShipmentCharge>()
                        .Select(s => new
                        {
                              s.intInventoryShipmentChargeId
                            , s.intInventoryShipmentId
                            , s.intContractId
                            , s.intContractDetailId
                            , s.intChargeId
                            , s.strCostMethod
                            , s.dblRate
                            , s.intCostUOMId
                            , s.intCurrencyId
                            , s.dblAmount
                            , s.dblAmountBilled
                            , s.dblAmountPaid
                            , s.dblAmountPriced
                            , s.strAllocatePriceBy
                            , s.ysnAccrue
                            , s.intEntityVendorId
                            , s.ysnPrice
                            , s.intSort
                            , s.intForexRateTypeId
                            , s.dblForexRate
                            , s.dblQuantity
                            , s.dblQuantityBilled
                            , s.dblQuantityPriced
                            , s.intTaxGroupId
                            , s.dblTax
                            , s.dblAdjustedTax
                            , s.strChargesLink
                            , s.vyuICGetInventoryShipmentCharge.strContractNumber
                            , s.vyuICGetInventoryShipmentCharge.strCostType
                            , s.vyuICGetInventoryShipmentCharge.strCostUOM
                            , s.vyuICGetInventoryShipmentCharge.strCurrency
                            , s.vyuICGetInventoryShipmentCharge.strForexRateType
                            , s.vyuICGetInventoryShipmentCharge.strItemDescription
                            , s.vyuICGetInventoryShipmentCharge.strItemNo
                            , s.vyuICGetInventoryShipmentCharge.strOnCostType
                            , s.vyuICGetInventoryShipmentCharge.strTaxGroup
                            , s.vyuICGetInventoryShipmentCharge.strUnitType
                            , s.vyuICGetInventoryShipmentCharge.strVendorId
                            , s.vyuICGetInventoryShipmentCharge.strVendorName
                            , s.tblICInventoryShipmentChargeTaxes
                        })
                        .Filter(param)
                        .AsNoTracking();
                return new GetObjectResult
                {
                    data = await query.Execute(param, key, "DESC").ToListAsync(param.cancellationToken),
                    total = await query.CountAsync(param.cancellationToken)
                };
            }
            catch(Exception ex)
            {
                return await Task.FromResult(new GetObjectResult
                {
                    data = ex.Message + (ex.InnerException != null ? ex.InnerException.Message : ""),
                    success = false,
                    total = 0
                });
            }
        }

        public async Task<GetObjectResult> GetShipmentItems(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryShipmentItem>().Filter(param);
            try
            {
                var data = await query
                    .Select(s => new
                    {
                        s.intInventoryShipmentItemId,
                        s.intInventoryShipmentId,
                        s.intOrderId,
                        s.intSourceId,
                        s.intLineNo,
                        s.intItemId,
                        s.strChargesLink,
                        s.intSubLocationId,
                        s.intStorageLocationId,
                        s.intOwnershipType,
                        s.dblQuantity,
                        s.intItemUOMId,
                        s.intCurrencyId,
                        s.intWeightUOMId,
                        s.dblUnitPrice,
                        s.intDockDoorId,
                        s.strNotes,
                        s.intGradeId,
                        s.intDiscountSchedule,
                        s.intSort,
                        s.intStorageScheduleTypeId,
                        s.intDestinationGradeId,
                        s.intDestinationWeightId,
                        s.dblDestinationQuantity,
                        s.intForexRateTypeId,
                        s.dblForexRate,
                        s.strItemType,
                        s.intParentItemLinkId,
                        s.intChildItemLinkId,
                        s.intConcurrencyId,

                        // PROJECTED 
                        s.vyuICGetInventoryShipmentItem.strOrderNumber,
                        s.vyuICGetInventoryShipmentItem.strSourceNumber,
                        s.vyuICGetInventoryShipmentItem.strItemNo,
                        s.vyuICGetInventoryShipmentItem.strItemDescription,
                        s.vyuICGetInventoryShipmentItem.strSubLocationName,
                        s.vyuICGetInventoryShipmentItem.strStorageLocationName,
                        strOwnershipType =
                            s.intOwnershipType == 1 ? "Own"
                            : s.intOwnershipType == 2 ? "Storage"
                            : s.intOwnershipType == 3 ? "Consigned Purchase"
                            : s.intOwnershipType == 4 ? "Consigned Sale"
                            : "Own",
                        s.vyuICGetInventoryShipmentItem.strUnitMeasure,
                        s.vyuICGetInventoryShipmentItem.strCurrency,
                        s.vyuICGetInventoryShipmentItem.strWeightUOM,
                        s.vyuICGetInventoryShipmentItem.strDockDoor,
                        s.vyuICGetInventoryShipmentItem.strGrade,
                        s.vyuICGetInventoryShipmentItem.strDiscountSchedule,
                        s.vyuICGetInventoryShipmentItem.strStorageTypeDescription,
                        s.vyuICGetInventoryShipmentItem.strDestinationGrades,
                        s.vyuICGetInventoryShipmentItem.strDestinationWeights,
                        s.vyuICGetInventoryShipmentItem.strForexRateType,

                        s.vyuICGetInventoryShipmentItem.intDecimalPlaces,
                        s.vyuICGetInventoryShipmentItem.intUnitMeasureId,
                        s.vyuICGetInventoryShipmentItem.strOrderUOM,
                        s.vyuICGetInventoryShipmentItem.dblQtyOrdered,
                        s.vyuICGetInventoryShipmentItem.dblQtyAllocated,
                        dblOrderUnitPrice = s.vyuICGetInventoryShipmentItem.dblUnitPrice,
                        dblOrderDiscount = s.vyuICGetInventoryShipmentItem.dblDiscount,
                        dblOrderTotal = s.vyuICGetInventoryShipmentItem.dblTotal,
                        dblUnitCost = s.vyuICGetInventoryShipmentItem.dblUnitCost,
                        s.vyuICGetInventoryShipmentItem.strLotTracking,
                        s.vyuICGetInventoryShipmentItem.dblItemUOMConv,
                        s.vyuICGetInventoryShipmentItem.dblWeightItemUOMConv,
                        s.vyuICGetInventoryShipmentItem.intCommodityId
                    })
                    .AsNoTracking()
                    .ToListAsync(param.cancellationToken);

                return new GetObjectResult()
                {
                    data = data,
                    total = await query.CountAsync(param.cancellationToken)
                };
            }
            catch(Exception ex)
            {
                return await Task.FromResult(new GetObjectResult
                {
                    data = ex.Message + (ex.InnerException != null ? ex.InnerException.Message : ""),
                    success = false,
                    total = 0
                });
            }
        }

        public override async Task<GetObjectResult> GetAsync(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryShipment>().Filter(param, true);
            var data = await query.Execute(param, "intInventoryShipmentId")
                        .Select(s => new
                        {
                            s.intInventoryShipmentId,
                            s.strShipmentNumber,
                            s.dtmShipDate,
                            s.intOrderType,
                            s.intSourceType,
                            s.strReferenceNumber,
                            s.dtmRequestedArrivalDate,
                            s.intShipFromLocationId,
                            s.intEntityCustomerId,
                            s.intShipToLocationId,
                            s.intFreightTermId,
                            s.intCurrencyId,
                            s.strFreeTime,
                            s.strBOLNumber,
                            s.intShipViaId,
                            s.strVessel,
                            s.strProNumber,
                            s.strDriverId,
                            s.strSealNumber,
                            s.strDeliveryInstruction,
                            s.dtmAppointmentTime,
                            s.dtmDepartureTime,
                            s.dtmArrivalTime,
                            s.dtmDeliveredDate,
                            s.strReceivedBy,
                            s.strComment,
                            s.ysnPosted,
                            s.intEntityId,
                            s.intCreatedUserId,
                            s.intShipToCompanyLocationId,
                            s.intConcurrencyId,

                            // PROJECTION
                            s.vyuICGetInventoryShipmentLookUp.strShipFromLocation,
                            s.vyuICGetInventoryShipmentLookUp.strShipFromStreet,
                            s.vyuICGetInventoryShipmentLookUp.strShipFromCity,
                            s.vyuICGetInventoryShipmentLookUp.strShipFromState,
                            s.vyuICGetInventoryShipmentLookUp.strShipFromZipPostalCode,
                            s.vyuICGetInventoryShipmentLookUp.strShipFromCountry,
                            s.vyuICGetInventoryShipmentLookUp.strShipToLocation,
                            s.vyuICGetInventoryShipmentLookUp.strShipToStreet,
                            s.vyuICGetInventoryShipmentLookUp.strShipToCity,
                            s.vyuICGetInventoryShipmentLookUp.strShipToState,
                            s.vyuICGetInventoryShipmentLookUp.strShipToZipPostalCode,
                            s.vyuICGetInventoryShipmentLookUp.strShipToCountry,
                            s.vyuICGetInventoryShipmentLookUp.strCustomerName,
                            s.vyuICGetInventoryShipmentLookUp.intWarehouseInstructionHeaderId,
                            s.vyuICGetInventoryShipmentLookUp.strShipVia,
                            s.vyuICGetInventoryShipmentLookUp.strCurrency,
                            s.vyuICGetInventoryShipmentLookUp.strFreightTerm

                        }).ToListAsync(param.cancellationToken);

            return new GetObjectResult()
            {
                data = data,
                total = await query.CountAsync(param.cancellationToken)
            };
        }

        public async Task<SearchResult> GetChargeTaxDetails(GetParameter param, int ChargeId, int ShipmentId)
        {
            var query = _db.GetQuery<vyuICGetShipmentChargeTaxDetails>()
                    .Where(p => p.intInventoryShipmentChargeId == ChargeId && p.intInventoryShipmentId == ShipmentId)
                    .Filter(param, true);

            var data = await query.ExecuteProjection(param, "intInventoryShipmentChargeTaxId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
