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
using iRely.Inventory.BusinessLayer;
using System.Web.Http.ModelBinding;
using System.Data.Entity.SqlServer;
using System.Data.Entity.Core.Objects;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryReceiptBl : BusinessLayer<tblICInventoryReceipt>, IInventoryReceiptBl 
    {
        #region Constructor
        public InventoryReceiptBl(IInventoryRepository db) : base(db)
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
            var query = _db.GetQuery<vyuICGetInventoryReceipt>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICInventoryReceipt entity)
        {
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public override async Task<GetObjectResult> GetAsync(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryReceipt>().Filter(param, true);
            var data = await query.Execute(param, "intInventoryReceiptId")
                        .Select(t => new
                        {
                            t.intInventoryReceiptId
                            , t.strReceiptType
                            , t.intSourceType
                            , t.intEntityVendorId
                            , t.intTransferorId
                            , t.intLocationId
                            , t.strReceiptNumber
                            , t.dtmReceiptDate
                            , t.intCurrencyId
                            , t.intSubCurrencyCents
                            , t.intBlanketRelease
                            , t.strVendorRefNo
                            , t.strBillOfLading
                            , t.intShipViaId
                            , t.intShipFromId
                            , t.intReceiverId
                            , t.strVessel
                            , t.intFreightTermId
                            , t.intShiftNumber
                            , t.dblInvoiceAmount
                            , t.ysnPrepaid
                            , t.ysnInvoicePaid
                            , t.intCheckNo
                            , t.dtmCheckDate
                            , t.intTrailerTypeId
                            , t.dtmTrailerArrivalDate
                            , t.dtmTrailerArrivalTime
                            , t.strSealNo
                            , t.strSealStatus
                            , t.dtmReceiveTime
                            , t.dblActualTempReading
                            , t.intShipmentId
                            , t.intTaxGroupId
                            , t.ysnPosted
                            , t.intCreatedUserId
                            , t.intEntityId
                            , t.intConcurrencyId
                            , t.strWarehouseRefNo
                            , t.ysnOrigin
                            , t.dtmLastFreeWhseDate

                            , strVendorName = t.vyuICInventoryReceiptLookUp.strVendorName
                            , intVendorEntityId = t.vyuICInventoryReceiptLookUp.intEntityId
                            , strFobPoint = t.vyuICInventoryReceiptLookUp.strFobPoint
                            , strLocationName = t.vyuICInventoryReceiptLookUp.strLocationName
                            , strCurrency = t.vyuICInventoryReceiptLookUp.strCurrency
                            , strFromLocation = t.vyuICInventoryReceiptLookUp.strFromLocation
                            , strUserName = t.vyuICInventoryReceiptLookUp.strUserName
                            , strShipFrom = t.vyuICInventoryReceiptLookUp.strShipFrom
                            , strShipVia = t.vyuICInventoryReceiptLookUp.strShipVia
                            , strFreightTerm = t.vyuICInventoryReceiptLookUp.strFreightTerm
                            , dblTotalCharge = t.vyuICInventoryReceiptTotals.dblTotalCharge
                            , dblTotalChargeTax = t.vyuICInventoryReceiptTotals.dblTotalChargeTax
                            , intItemCount = t.tblICInventoryReceiptItems.Count()
                        }).ToListAsync(param.cancellationToken);

            return new GetObjectResult()
            {
                data = data,
                total = await query.CountAsync(param.cancellationToken)
            };
        }

        public async Task<GetObjectResult> GetReceiptItems(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryReceiptItem>()
                .Filter(param);

            var data = await query
                .Select(s => new
                {
                    s.intInventoryReceiptItemId,
                    s.intInventoryReceiptId,
                    s.intLineNo,
                    s.intOrderId,
                    s.intSourceId,
                    s.intItemId,
                    s.intContainerId,
                    s.intSubLocationId,
                    s.intStorageLocationId,
                    s.intOwnershipType,
                    s.dblOrderQty,
                    s.dblBillQty,
                    s.dblOpenReceive,
                    s.intLoadReceive,
                    s.intUnitMeasureId,
                    s.intWeightUOMId,
                    s.intCostUOMId,
                    s.dblUnitCost,
                    s.dblUnitRetail,
                    s.ysnSubCurrency,
                    s.dblLineTotal,
                    s.intGradeId,
                    s.dblGross,
                    s.dblNet,
                    s.dblTax,
                    s.intDiscountSchedule,
                    s.ysnExported,
                    s.dtmExportedDate,
                    s.intSort,
                    s.intConcurrencyId,
                    s.intTaxGroupId,
                    s.intForexRateTypeId,
                    s.dblForexRate,
                    s.strChargesLink,

                    s.strItemType,
                    s.intParentItemLinkId,
                    s.intChildItemLinkId,

                    // PROJECTED
                    strItemNo = s.tblICItem.strItemNo,
                    strItemDescription = s.tblICItem.strDescription,
                    strOrderNumber = s.vyuICInventoryReceiptItemLookUp.strOrderNumber,
                    strSourceNumber = s.vyuICInventoryReceiptItemLookUp.strSourceNumber,
                    dtmOrderDate = s.vyuICInventoryReceiptItemLookUp.dtmDate,
                    strLotTracking = s.tblICItem.strLotTracking,
                    strOrderUOM = s.vyuICInventoryReceiptItemLookUp.strOrderUOM,
                    dblOrdered = s.vyuICInventoryReceiptItemLookUp.dblOrdered,
                    dblReceived = s.vyuICInventoryReceiptItemLookUp.dblReceived,
                    dblOrderUOMConvFactor = s.vyuICInventoryReceiptItemLookUp.dblOrderUOMConvFactor,
                    strUnitMeasure = s.vyuICInventoryReceiptItemLookUp.strUnitMeasure,
                    intItemUOMId = s.vyuICInventoryReceiptItemLookUp.intItemUOMId,
                    intItemUOMDecimalPlaces = s.vyuICInventoryReceiptItemLookUp.intItemUOMDecimalPlaces,
                    strUnitType = s.vyuICInventoryReceiptItemLookUp.strUnitType,
                    strSubLocationName = s.vyuICInventoryReceiptItemLookUp.strSubLocationName,
                    strStorageLocationName = s.vyuICInventoryReceiptItemLookUp.strStorageLocationName,
                    strGrade = s.vyuICInventoryReceiptItemLookUp.strGrade,
                    strOwnershipType = s.intOwnershipType == 1 ? "Own"
                        : s.intOwnershipType == 2 ? "Storage"
                        : s.intOwnershipType == 3 ? "Consigned Purchase"
                        : s.intOwnershipType == 4 ? "Consigned Sale"
                        : "Own",
                    intCommodityId = s.vyuICInventoryReceiptItemLookUp.intCommodityId,
                    strWeightUOM = s.vyuICInventoryReceiptItemLookUp.strWeightUOM,
                    intWeightUnitMeasureId = s.vyuICInventoryReceiptItemLookUp.intWeightUnitMeasureId,
                    strContainer = s.vyuICInventoryReceiptItemLookUp.strContainer,
                    dblItemUOMConvFactor = s.vyuICInventoryReceiptItemLookUp.dblItemUOMConvFactor,
                    dblWeightUOMConvFactor = s.vyuICInventoryReceiptItemLookUp.dblWeightUOMConvFactor,
                    dblGrossMargin = s.vyuICInventoryReceiptItemLookUp.dblGrossMargin,
                    strLifeTimeType = s.vyuICInventoryReceiptItemLookUp.strLifeTimeType,
                    intLifeTime = s.vyuICInventoryReceiptItemLookUp.intLifeTime,
                    strCostUOM = s.vyuICInventoryReceiptItemLookUp.strCostUOM,
                    dblCostUOMConvFactor = s.vyuICInventoryReceiptItemLookUp.dblCostUOMConvFactor,
                    ysnLoad = s.vyuICInventoryReceiptItemLookUp.ysnLoad,
                    dblAvailableQty = s.vyuICInventoryReceiptItemLookUp.dblAvailableQty,
                    strDiscountSchedule = s.vyuICInventoryReceiptItemLookUp.strDiscountSchedule,
                    dblFranchise = s.vyuICInventoryReceiptItemLookUp.dblFranchise,
                    dblContainerWeightPerQty = s.vyuICInventoryReceiptItemLookUp.dblContainerWeightPerQty,
                    intContainerWeightUOMId = s.vyuICInventoryReceiptItemLookUp.intContainerWeightUOMId,
                    dblContainerWeightUOMConvFactor = s.vyuICInventoryReceiptItemLookUp.dblContainerWeightUOMConvFactor,
                    strSubCurrency = s.vyuICInventoryReceiptItemLookUp.strSubCurrency,
                    strPricingType = s.vyuICInventoryReceiptItemLookUp.strPricingType,
                    strTaxGroup = s.vyuICInventoryReceiptItemLookUp.strTaxGroup,
                    strForexRateType = s.vyuICInventoryReceiptItemLookUp.strForexRateType,
                    intContractSeq = s.vyuICInventoryReceiptItemLookUp.intContractSeq,
                    tblICInventoryReceiptItemTaxes = s.tblICInventoryReceiptItemTaxes
                })
                .AsNoTracking()
                .ToListAsync(param.cancellationToken);

            return new GetObjectResult()
            {
                data = data
            };
        }

        public async Task<GetObjectResult> GetReceiptInspections(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryReceiptInspection>().Filter(param);
            var data = await query.AsNoTracking().ToListAsync(param.cancellationToken);

            return new GetObjectResult()
            {
                data = data,
                total = await query.CountAsync(param.cancellationToken)
            };
        }

        public async Task<GetObjectResult> GetReceiptCharges(GetParameter param)
        {
            var key = Methods.GetPrimaryKey<vyuICGetInventoryReceiptCharge>(_db.ContextManager);
            try
            {
                var query = _db.GetQuery<tblICInventoryReceiptCharge>()
                    .Select(s => new
                    {
                        s.dblAmount,
                        s.dblAmountBilled,
                        s.dblAmountPaid,
                        s.dblAmountPriced,
                        s.dblForexRate,
                        s.dblQuantity,
                        s.dblRate,
                        s.dblTax,
                        s.intChargeId,
                        s.intConcurrencyId,
                        s.intContractId,
                        s.intCostUOMId,
                        s.intEntityVendorId,
                        s.intForexRateTypeId,
                        s.intInventoryReceiptChargeId,
                        s.intInventoryReceiptId,
                        s.intSort,
                        s.intTaxGroupId,
                        s.strAllocateCostBy,
                        s.strChargesLink,
                        s.strCostMethod,
                        s.ysnAccrue,
                        s.ysnInventoryCost,
                        s.ysnPrice,
                        s.ysnSubCurrency,
                        s.vyuICGetInventoryReceiptCharge.dtmReceiptDate,
                        s.vyuICGetInventoryReceiptCharge.intContractSeq,
                        s.vyuICGetInventoryReceiptCharge.intCostUnitMeasureId,
                        s.vyuICGetInventoryReceiptCharge.intOnCostTypeId,
                        s.vyuICGetInventoryReceiptCharge.strBillOfLading,
                        s.vyuICGetInventoryReceiptCharge.strContractNumber,
                        s.vyuICGetInventoryReceiptCharge.strCostType,
                        s.vyuICGetInventoryReceiptCharge.strCostUOM,
                        s.vyuICGetInventoryReceiptCharge.strCurrency,
                        s.vyuICGetInventoryReceiptCharge.strForexRateType,
                        s.vyuICGetInventoryReceiptCharge.strItemDescription,
                        s.vyuICGetInventoryReceiptCharge.strItemNo,
                        s.vyuICGetInventoryReceiptCharge.strLocationName,
                        s.vyuICGetInventoryReceiptCharge.strOnCostType,
                        s.vyuICGetInventoryReceiptCharge.strReceiptNumber,
                        s.vyuICGetInventoryReceiptCharge.strReceiptVendor,
                        s.vyuICGetInventoryReceiptCharge.strTaxGroup,
                        s.vyuICGetInventoryReceiptCharge.strUnitType,
                        s.vyuICGetInventoryReceiptCharge.strVendorId,
                        s.vyuICGetInventoryReceiptCharge.strVendorName,
                        s.vyuICGetInventoryReceiptCharge.tblICInventoryReceiptCharge.tblICInventoryReceiptChargeTaxes
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
            //return new GetObjectResult()
            //{
            //    data = await query.Execute(param, key, "DESC").ToListAsync(param.cancellationToken),
            //    total = await query.CountAsync(param.cancellationToken)
            //};
        }

        public override async Task<BusinessResult<tblICInventoryReceipt>> SaveAsync(bool continueOnConflict)
        {
            SaveResult result = new SaveResult();
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;

            var addedReceipts = _db.ContextManager.ChangeTracker.Entries<tblICInventoryReceipt>().Where(w => w.State == EntityState.Added);
            foreach (var receipt in addedReceipts) {
                receipt.Entity.strReceiptNumber = db.GetStartingNumber((int)Common.StartingNumber.InventoryReceipt, receipt.Entity.intLocationId);
            }

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    // Get the deleted receipt records
                    var deletedReceipts = _db.ContextManager.ChangeTracker.Entries<tblICInventoryReceipt>().Where(p => p.State == EntityState.Deleted).ToList();

                    // Log the original data. 
                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        // Clear the receipt per charge records. Let the Receipt posting re-create it. 
                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICDeleteChargePerItemOnReceiptSave @intReceiptNo",
                            new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId)
                        );

                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICLogTransactionDetail @TransactionType, @TransactionId", 
                            new SqlParameter("TransactionType", 1),
                            new SqlParameter("TransactionId", receipt.intInventoryReceiptId)
                        );
                    }

                    // Log the original data from the deleted receipts.
                    foreach (var receipt in deletedReceipts)
                    {
                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICLogTransactionDetail @TransactionType, @TransactionId",
                            new SqlParameter("TransactionType", 1),
                            new SqlParameter("TransactionId", receipt.Entity.intInventoryReceiptId)
                        );

                        // Update the PO or Scale status from deleted shipment records.
                        // Usually, deleted records will "open" the status of the PO or Scale Ticket.
                        // Call this sp before the _db.SaveAsync because uspICUpdateStatusOnShipmentSave is not reading it from the log table. 
                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICUpdateStatusOnReceiptSave @intReceiptNo, @ysnOpenStatus",
                            new SqlParameter("intReceiptNo", receipt.Entity.intInventoryReceiptId),
                            new SqlParameter("ysnOpenStatus", true)
                        );                    
                    }

                    // Save the data
                    result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);

                    // Process the deleted receipts. 
                    foreach (var receipt in deletedReceipts)
                    {
                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId",
                            new SqlParameter("ReceiptId", receipt.Entity.intInventoryReceiptId), 
                            new SqlParameter("ForDelete", true), 
                            new SqlParameter("UserId", DefaultUserId)
                        );
                    }                   

                    // Process the newly saved data. 
                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        // Validate locations
                        var rid = new SqlParameter("intTransactionId", receipt.intInventoryReceiptId);
                        
                        var ysnValidLocation = new SqlParameter("ysnValidLocation", SqlDbType.Bit);                        
                        ysnValidLocation.Direction = ParameterDirection.Output;

                        var strItemNo = new SqlParameter("strItemNo", SqlDbType.NVarChar);
                        strItemNo.Size = 50; 
                        strItemNo.Direction = ParameterDirection.Output;

                        _db.ContextManager.Database.ExecuteSqlCommand("uspICValidateReceiptItemLocations @intTransactionId, @ysnValidLocation OUTPUT, @strItemNo OUTPUT", rid, ysnValidLocation, strItemNo);
                        if ((bool)ysnValidLocation.Value == false)
                        {
                            //throw new Exception("Please ensure that the line items and lots are located in the receipt's origin.");
                            var msg = System.String.Format("The storage location and storage unit in {0} does not match.", strItemNo.Value);
                            throw new Exception(msg); 
                        }

                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICUpdateStatusOnReceiptSave @intReceiptNo"
                            , new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId)
                        );

                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                            "uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId",
                            new SqlParameter("ReceiptId", receipt.intInventoryReceiptId), 
                            new SqlParameter("ForDelete", false), 
                            new SqlParameter("UserId", DefaultUserId)
                        );

                        //Update Quality Receipt Inspection
                        await _db.ContextManager.Database.ExecuteSqlCommandAsync(
                         "uspICSaveReceiptInspection @ReceiptId",
                         new SqlParameter("ReceiptId", receipt.intInventoryReceiptId)
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

            return new BusinessResult<tblICInventoryReceipt>()
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


        public SaveResult ProcessBill(int receiptId, out int? newBill, out string newBills)
        {
            SaveResult saveResult = new SaveResult();
            newBill = null;
            newBills = String.Empty;
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.ProcessBill(receiptId, out newBill, out newBills);
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

        public SaveResult CalculateCharges(int receiptId)
        {
            SaveResult saveResult = new SaveResult();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("@intInventoryReceiptId", receiptId);
                    _db.ContextManager.Database.ExecuteSqlCommand("uspICCalculateOtherCharges @intInventoryReceiptId", idParameter);
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
            return saveResult;
        }

        public Common.GLPostResult PostReceive(Common.Posting_RequestModel receipt, bool isRecap)
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
                if (receipt.isPost)
                {
                    strBatchId = db.PostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    strBatchId = db.UnpostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetEntityId());
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

        public Common.GLPostResult PostReturn(Common.Posting_RequestModel receipt, bool isRecap)
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
                glPostResult.strBatchId = null;

                return glPostResult;
            }

            // Post the receipt transaction 
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                string strBatchId;
                if (receipt.isPost)
                {
                    strBatchId = db.PostInventoryReturn(isRecap, receipt.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    strBatchId = db.UnpostInventoryReturn(isRecap, receipt.strTransactionId, iRely.Common.Security.GetEntityId());
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

        public async Task<SearchResult> SearchReceiptItems(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptItem>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync(param.cancellationToken);

            // Remove Qty to Receive and Unit Cost in the aggregrates because each item can have its own UOM. This means, total becomes irrelevant. 
            if (param != null && param.aggregates != null) {
                param.aggregates = param.aggregates.Replace("dblQtyToReceive|sum:", "");
                param.aggregates = param.aggregates.Replace("dblUnitCost|sum:", "");
            }                       

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchReceiptItemView(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemView>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchReceiptItemLots(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemLot>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetAddOrders(GetParameter param, int VendorId, string ReceiptType, int SourceType, int CurrencyId)
        {
            if (ReceiptType == "Transfer Order")
            {
                // Get the Transfer Orders
                // Note: VendorId becomes a location id when receipt type is a "Transfer Order"
                var query = _db.GetQuery<vyuICGetReceiptAddTransferOrder>()
                    .Where(p => p.strReceiptType == ReceiptType && p.intSourceType == SourceType && p.intCurrencyId == CurrencyId && p.intLocationId == VendorId)
                    .Filter(param, true);

                var sorts = new List<SearchSort>();

                foreach (var ps in param.sort)
                {
                    // Use the direction specified by the caller. 
                    if (ps.property.ToLower() == "strordernumber" && ps.direction == "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "ASC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "ASC" });
                    }

                    else if (ps.property.ToLower() == "strordernumber" && ps.direction != "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "DESC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "DESC" });
                    }
                }

                sorts.AddRange(param.sort.ToList());
                param.sort = sorts;

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync(param.cancellationToken);

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else if (ReceiptType == "Purchase Contract" && SourceType == 0)
            {
                // Get Contracts that are "Purchase" type. 
                var query = _db.GetQuery<vyuICGetReceiptAddPurchaseContract>()
                    .Where(p => p.strReceiptType == ReceiptType && p.intSourceType == SourceType && p.intCurrencyId == CurrencyId && p.intEntityVendorId == VendorId)
                    .Filter(param, true);

                var sorts = new List<SearchSort>();

                foreach (var ps in param.sort)
                {
                    // Use the direction specified by the caller. 
                    if (ps.property.ToLower() == "strordernumber" && ps.direction == "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "ASC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "ASC" });
                    }

                    else if (ps.property.ToLower() == "strordernumber" && ps.direction != "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "DESC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "DESC" });
                    }
                }

                sorts.AddRange(param.sort.ToList());
                param.sort = sorts;

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync(param.cancellationToken);

                return new SearchResult() {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else if (ReceiptType == "Purchase Contract" && SourceType == 2)
            {
                // Get Purchase Contracts that are linked with Logistic's Inbound Shipments 
                var query = _db.GetQuery<vyuICGetReceiptAddLGInboundShipment>()
                    .Where(p => p.strReceiptType == ReceiptType && p.intSourceType == SourceType && p.intCurrencyId == CurrencyId && p.intEntityVendorId == VendorId)
                    .Filter(param, true);

                var sorts = new List<SearchSort>();

                foreach (var ps in param.sort)
                {
                    // Use the direction specified by the caller. 
                    if (ps.property.ToLower() == "strordernumber" && ps.direction == "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "ASC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "ASC" });
                    }

                    else if (ps.property.ToLower() == "strordernumber" && ps.direction != "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "DESC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "DESC" });
                    }
                }

                sorts.AddRange(param.sort.ToList());
                param.sort = sorts;

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync(param.cancellationToken);

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else 
            {
                // Get the Purchase Orders
                var query = _db.GetQuery<vyuICGetReceiptAddPurchaseOrder>()
                    .Where(p => p.strReceiptType == ReceiptType && p.intSourceType == SourceType && p.intCurrencyId == CurrencyId && p.intEntityId == VendorId)
                    .Filter(param, true);

                var sorts = new List<SearchSort>();

                foreach (var ps in param.sort)
                {
                    // Use the direction specified by the caller. 
                    if (ps.property.ToLower() == "strordernumber" && ps.direction == "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "ASC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "ASC" });
                    }

                    else if (ps.property.ToLower() == "strordernumber" && ps.direction != "ASC")
                    {
                        sorts.Add(new SearchSort() { property = "intOrderId", direction = "DESC" });
                        sorts.Add(new SearchSort() { property = "intKey", direction = "DESC" });
                    }
                }

                sorts.AddRange(param.sort.ToList());
                param.sort = sorts;

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync(param.cancellationToken);

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(param.cancellationToken),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }

        }

        public async Task<SearchResult> SearchReceiptVouchers(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptVoucher>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strallvouchers" && ps.direction == "ASC")
                {
                    //sorts.Add(new SearchSort() { property = "intBillId", direction = "ASC" });
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strallvouchers" && ps.direction == "DESC")
                {
                    //sorts.Add(new SearchSort() { property = "intBillId", direction = "DESC" });
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "DESC" });
                }

                else if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;
                        
            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public SaveResult UpdateReceiptInspection(int receiptId)
        {
            SaveResult saveResult = new SaveResult();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("@intInventoryReceiptId", receiptId);
                    _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdateTableReceiptInspection @intInventoryReceiptId", idParameter);
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

        public SaveResult GetTaxGroupId(int receiptId, out int? taxGroup, out string taxGroupName)
        {
            SaveResult saveResult = new SaveResult();
            taxGroup = null;
            taxGroupName = String.Empty;
            try
            {
                var taxGroupOnInventoryReceipt = new iRely.Inventory.Model.TaxGroupOnInventoryReceipt();

                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                taxGroupOnInventoryReceipt = db.GetTaxGroupIdOnInventoryReceipt(receiptId);

                taxGroup = taxGroupOnInventoryReceipt.intTaxGroupId;
                taxGroupName = taxGroupOnInventoryReceipt.strTaxGroupId;

                saveResult.HasError = false; 
            }
            catch (Exception ex)
            {
                saveResult.BaseException = ex;
                saveResult.Exception = new ServerException(ex);
                saveResult.HasError = true;
            }

            return saveResult;
        }        

        public SaveResult GetDefaultReceiptTaxGroupId(int? freightTermId, int? locationId, int? itemId, int? entityVendorId, int? entityLocationId, out int? taxGroup, out string taxGroupName)
        {
            SaveResult saveResult = new SaveResult();
            taxGroup = null;
            taxGroupName = null;

            try
            {
                var freightTermIdParam = new SqlParameter("@intFreightTermId", freightTermId);
                freightTermIdParam.DbType = System.Data.DbType.Int32;
                freightTermIdParam.SqlDbType = System.Data.SqlDbType.Int;
                if (freightTermId == null)
                    freightTermIdParam.Value = DBNull.Value; 
                else
                    freightTermIdParam.Value = freightTermId;

                var locationIdParam = new SqlParameter("@intLocationId", locationId);
                locationIdParam.DbType = System.Data.DbType.Int32;
                locationIdParam.SqlDbType = System.Data.SqlDbType.Int;
                if (locationId == null)
                    locationIdParam.Value = DBNull.Value;
                else
                    locationIdParam.Value = locationId;

                var itemIdParam = new SqlParameter("@intItemId", itemId);
                itemIdParam.DbType = System.Data.DbType.Int32;
                itemIdParam.SqlDbType = System.Data.SqlDbType.Int;
                if (itemId == null)
                    itemIdParam.Value = DBNull.Value;
                else
                    itemIdParam.Value = itemId;
                
                var entityVendorIdParam = new SqlParameter("@intEntityVendorId", entityVendorId);
                entityVendorIdParam.DbType = System.Data.DbType.Int32;
                entityVendorIdParam.SqlDbType = System.Data.SqlDbType.Int;
                if (entityVendorId == null)
                    entityVendorIdParam.Value = DBNull.Value;
                else
                    entityVendorIdParam.Value = entityVendorId;

                var entityLocationIdParam = new SqlParameter("@intEntityLocationId", entityLocationId);
                entityLocationIdParam.DbType = System.Data.DbType.Int32;
                entityLocationIdParam.SqlDbType = System.Data.SqlDbType.Int;
                if (entityLocationId == null)
                    entityLocationIdParam.Value = DBNull.Value;
                else
                    entityLocationIdParam.Value = entityLocationId;

                var intTaxGroupIdOutput = new SqlParameter("@intTaxGroupId", SqlDbType.Int);
                intTaxGroupIdOutput.Direction = System.Data.ParameterDirection.Output;
                intTaxGroupIdOutput.DbType = System.Data.DbType.Int32;

                var strTaxGroupOutput = new SqlParameter("@strTaxGroup", SqlDbType.NVarChar);
                strTaxGroupOutput.Direction = System.Data.ParameterDirection.Output;
                strTaxGroupOutput.DbType = System.Data.DbType.String;
                strTaxGroupOutput.Size = 50;

                _db.ContextManager.Database.ExecuteSqlCommand(
                    "uspICGetDefaultReceiptTaxGroupId @intFreightTermId, @intLocationId, @intItemId, @intEntityVendorId, @intEntityLocationId, @intTaxGroupId OUTPUT, @strTaxGroup OUTPUT"
                    , freightTermIdParam
                    , locationIdParam
                    , itemIdParam 
                    , entityVendorIdParam
                    , entityLocationIdParam
                    , intTaxGroupIdOutput
                    , strTaxGroupOutput
                );

                taxGroup = (intTaxGroupIdOutput.Value == DBNull.Value) ? null : (int?)intTaxGroupIdOutput.Value;
                taxGroupName = (strTaxGroupOutput.Value == DBNull.Value) ? null : (string)strTaxGroupOutput.Value;
                saveResult.HasError = false;
            }
            catch (Exception ex)
            {
                saveResult.BaseException = ex;
                saveResult.Exception = new ServerException(ex);
                saveResult.HasError = true;
            }
            return saveResult;
        }

        public async Task<SearchResult> GetChargeTaxDetails(GetParameter param, int ReceiptChargeId, int ReceiptId)
        {
            var query = _db.GetQuery<vyuICGetChargeTaxDetails>()
                    .Where(p => p.intInventoryReceiptChargeId == ReceiptChargeId && p.intInventoryReceiptId == ReceiptId)
                    .Filter(param, true);

            var data = await query.ExecuteProjection(param, "intKey").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public SaveResult GetStatusUnitCost(int receiptId, out int? newStatus)
        {
            SaveResult saveResult = new SaveResult();
            int? newStatusResult = null;

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("intReceiptId", receiptId);
                    var outParam = new SqlParameter("@intReceiptItemsStatusId", newStatusResult);
                    outParam.Direction = System.Data.ParameterDirection.Output;
                    outParam.DbType = System.Data.DbType.Int32;
                    outParam.SqlDbType = System.Data.SqlDbType.Int;
                    _db.ContextManager.Database.ExecuteSqlCommand("uspICGetStatusUnitCost @intReceiptId, @intReceiptItemsStatusId OUTPUT", idParameter, outParam);
                    newStatusResult = (int)outParam.Value;
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
            newStatus = newStatusResult;
            return saveResult;
        }

        public SaveResult ReturnReceipt(int receiptId, out int? inventoryReturnId)
        {
            SaveResult saveResult = new SaveResult();
            inventoryReturnId = null;

            try
            {
                var inventoryReturnIdOutput = new SqlParameter("@intInventoryReturnId", SqlDbType.Int);
                inventoryReturnIdOutput.Direction = System.Data.ParameterDirection.Output;
                inventoryReturnIdOutput.DbType = System.Data.DbType.Int32;

                _db.ContextManager.Database.ExecuteSqlCommand(
                    "uspICReturnReceipt @intReceiptId, @intEntityUserSecurityId, @intInventoryReturnId OUTPUT"
                    , new SqlParameter("intReceiptId", receiptId)
                    , new SqlParameter("@intEntityUserSecurityId", iRely.Common.Security.GetEntityId())
                    , inventoryReturnIdOutput
                );

                inventoryReturnId = (int)inventoryReturnIdOutput.Value;
                saveResult.HasError = false;
            }
            catch (Exception ex)
            {
                //if (ex.Message.Contains("Please setup default AP Account"))
                //{
                //    ex = new Exception("Please setup default AP Account.", ex.InnerException);
                //}
                //else if (ex.Message.Contains("All of the item in the receipt was fully billed"))
                //{
                //    ex = new Exception("All of the item in the receipt was fully billed.", ex.InnerException);
                //}

                saveResult.BaseException = ex;
                saveResult.Exception = new ServerException(ex);
                saveResult.HasError = true;
            }
            return saveResult;
        }

        public async Task<SearchResult> SearchReceiptCharges(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptCharge>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strreceiptnumber" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public SaveResult UpdateReceiptVoucher()
        {
            SaveResult saveResult = new SaveResult();

            // Populate the Receipt Voucher
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.PopulateReceiptVoucher();
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

        public SaveResult CheckReceiptForValidReturn(int? receiptId)
        {
            SaveResult saveResult = new SaveResult();

            // Check the receipt
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.ValidateReceiptForReturn(receiptId);
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

        public async Task<decimal> CalculateGrossQtyRatio(int intItemUOMId, int intGrossUOMId, decimal dblQty, decimal dblProposedQty, decimal dblProposedGrossQty)
        {
            try
            {
                var db = (InventoryEntities)_db.ContextManager;
                return await db.CalculateGrossQtyRatio(intItemUOMId, intGrossUOMId, dblQty, dblProposedQty, dblProposedGrossQty);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
        public async Task<SearchResult> GetReceiptTaxView(GetParameter param, int ReceiptId)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemTax>()
                .Where(p => p.intInventoryReceiptId == ReceiptId)
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryReceiptItemTaxId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
