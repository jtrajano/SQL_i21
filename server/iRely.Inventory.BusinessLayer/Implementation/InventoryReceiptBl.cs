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

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryReceiptBl : BusinessLayer<tblICInventoryReceipt>, IInventoryReceiptBl 
    {
        #region Constructor
        public InventoryReceiptBl(IRepository db) : base(db)
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

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICInventoryReceipt entity)
        {
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        //public override void Update(tblICInventoryReceipt entity)
        //{
        //    var item = entity.tblICInventoryReceiptItems.First();
        //    if (item != null)
        //    {
        //        var itemTax = new tblICInventoryReceiptItemTax();
        //         itemTax.intTaxGroupMasterId = itemDetailTax.intTaxGroupMasterId;
        //         itemTax.intTaxGroupId = itemDetailTax.intTaxGroupId,
        //         itemTax.intTaxCodeId = itemDetailTax.intTaxCodeId,
        //         itemTax.intTaxClassId = itemDetailTax.intTaxClassId,
        //         itemTax.strTaxCode = itemDetailTax.strTaxCode,
        //         itemTax.strTaxableByOtherTaxes = itemDetailTax.strTaxableByOtherTaxes,
        //         itemTax.strCalculationMethod = itemDetailTax.strCalculationMethod,
        //         itemTax.dblRate = itemDetailTax.dblRate,
        //         itemTax.dblTax = itemDetailTax.dblTax,
        //         itemTax.dblAdjustedTax = 0;
        //         itemTax.intTaxAccountId = null;
        //         itemTax.ysnTaxAdjusted = false;
        //         itemTax.ysnSeparateOnInvoice = false;
        //         itemTax.ysnCheckoffTax = false;
        //        item.tblICInventoryReceiptItemTaxes.Add(itemTax);
        //    }

        //    base.Update(entity);
        //}

        //public override async Task<BusinessResult<tblICInventoryReceipt>> SaveAsync(bool continueOnConflict)
        //{
        //    SaveResult result = new SaveResult();

        //    using (var transaction = _db.ContextManager.Database.BeginTransaction())
        //    {
        //        var connection = _db.ContextManager.Database.Connection;
        //        try
        //        {
        //            int? ReceiptId = null;
        //            bool ysnDeleted = false;
        //            foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
        //            {
        //                ReceiptId = receipt.intInventoryReceiptId;
        //                if (receipt.strReceiptType == "Purchase Order")
        //                {
        //                    var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
        //                    var openStatus = new SqlParameter("ysnOpenStatus", true);
        //                    _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo, @ysnOpenStatus", idParameter, openStatus);
        //                }
        //            }
        //            var deletedReceipts = _db.ContextManager.ChangeTracker.Entries<tblICInventoryReceipt>().Where(p => p.State == EntityState.Deleted).ToList();
        //            foreach (var receipt in deletedReceipts)
        //            {
        //                ReceiptId = receipt.Entity.intInventoryReceiptId;
        //                ysnDeleted = true;
        //                if (receipt.Entity.strReceiptType == "Purchase Order")
        //                {
        //                    var idParameter = new SqlParameter("intReceiptNo", receipt.Entity.intInventoryReceiptId);
        //                    var openStatus = new SqlParameter("ysnOpenStatus", true);
        //                    _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo, @ysnOpenStatus", idParameter, openStatus);
        //                }
        //            }

        //            _db.ContextManager.Database.ExecuteSqlCommand("uspICLogTransactionDetail @TransactionType, @TransactionId", new SqlParameter("TransactionType", 1), new SqlParameter("TransactionId", ReceiptId));

        //            result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);

        //            foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
        //            {
        //                ReceiptId = receipt.intInventoryReceiptId;
        //                var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
        //                _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo", idParameter);

        //                //if (receipt.strReceiptType == "Purchase Order")
        //                //{
        //                //    var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
        //                //    _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo", idParameter);
        //                //}


        //                _db.ContextManager.Database.ExecuteSqlCommand("uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId", new SqlParameter("ReceiptId", ReceiptId), new SqlParameter("ForDelete", ysnDeleted), new SqlParameter("UserId", DefaultUserId));
        //            }

        //            foreach (var receipt in deletedReceipts)
        //            {
        //                ReceiptId = receipt.Entity.intInventoryReceiptId;
        //                ysnDeleted = true;
        //                _db.ContextManager.Database.ExecuteSqlCommand("uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId", new SqlParameter("ReceiptId", ReceiptId), new SqlParameter("ForDelete", ysnDeleted), new SqlParameter("UserId", DefaultUserId));
        //            }

        //            if (result.HasError)
        //            {
        //                throw result.BaseException;
        //            }
        //            transaction.Commit();
        //        }
        //        catch (Exception ex)
        //        {
        //            result.BaseException = ex;
        //            result.Exception = new ServerException(ex);
        //            result.HasError = true;
        //            //transaction.Rollback();
        //        }
        //    }

        //    return new BusinessResult<tblICInventoryReceipt>()
        //    {
        //        success = !result.HasError,
        //        message = new MessageResult()
        //        {
        //            statusText = result.Exception.Message,
        //            status = result.Exception.Error,
        //            button = result.Exception.Button.ToString()
        //        }
        //    };
        //}

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
            int? newBillId = null;
            string newBillIds = string.Empty;
            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("intReceiptId", receiptId);
                    var userId = new SqlParameter("@intUserId", iRely.Common.Security.GetEntityId());
                    var outParam = new SqlParameter("@intBillId", newBillId);
                    outParam.Direction = System.Data.ParameterDirection.Output;
                    outParam.DbType = System.Data.DbType.Int32;
                    outParam.SqlDbType = System.Data.SqlDbType.Int;

                    var outParam2 = new SqlParameter("@strBillIds", newBillIds);
                    outParam2.Direction = ParameterDirection.Output;
                    outParam2.DbType = DbType.String;
                    outParam2.Size = -1;
                    outParam2.SqlDbType = SqlDbType.NVarChar;

                    var prefix = new SqlParameter("@strPrefix", "^|");
                    var suffix = new SqlParameter("@strSuffix", "|");

                    _db.ContextManager.Database.ExecuteSqlCommand("uspICProcessToBill @intReceiptId, @intUserId, @intBillId OUTPUT, @strBillIds OUTPUT, @strPrefix, @strSuffix", idParameter, userId, outParam, outParam2, prefix, suffix);
                    newBillId = (int)outParam.Value;
                    var ids = outParam2.Value.ToString();
                    if(ids.Length > 0)
                    {
                        ids = ids.Substring(1, ids.Length - 2);
                    }
                    newBillIds = ids;
                    saveResult = _db.Save(false);
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("Please setup default AP Account"))
                    {
                        ex = new Exception("Please setup default AP Account.", ex.InnerException);
                    }
                    else if (ex.Message.Contains("All of the item in the receipt was fully billed"))
                    {
                        ex = new Exception("All of the item in the receipt was fully billed.", ex.InnerException);
                    }

                    saveResult.BaseException = ex;
                    saveResult.Exception = new ServerException(ex);
                    saveResult.HasError = true;
                }
            }
            newBill = newBillId;
            newBills = newBillIds;
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

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();
            var countDistinctUOM = await query.Select(q => q.strUnitMeasure).Distinct().CountAsync();

            param.aggregates = countDistinctUOM == 1? param.aggregates : param.aggregates.Replace("dblQtyToReceive|sum:", "");

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchReceiptItemView(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemView>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
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

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
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

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
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

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult() {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
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

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
                    summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else 
            {
                // Get the Purchase Orders
                var query = _db.GetQuery<vyuICGetReceiptAddPurchaseOrder>()
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

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
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
                        
            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
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
            int? newTaxGroupId = null;
            string newTaxGroupName = null;

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    var idParameter = new SqlParameter("@ReceiptId", receiptId);
                    var outParam = new SqlParameter("@intTaxGroupId", newTaxGroupId);
                    outParam.Direction = System.Data.ParameterDirection.Output;
                    outParam.DbType = System.Data.DbType.Int32;
                    outParam.SqlDbType = System.Data.SqlDbType.Int;
                    var outParam2 = new SqlParameter("@strTaxGroup", newTaxGroupName);
                    outParam2.Direction = System.Data.ParameterDirection.Output;
                    outParam2.DbType = System.Data.DbType.String;
                    outParam2.SqlDbType = System.Data.SqlDbType.NVarChar;
                    outParam2.Size = 50;

                    _db.ContextManager.Database.ExecuteSqlCommand("uspICGetTaxGroupIdOnInventoryReceipt @ReceiptId, @intTaxGroupId OUTPUT, @strTaxGroup OUTPUT", idParameter, outParam, outParam2);
                    newTaxGroupId = (int)outParam.Value;
                    newTaxGroupName = (string)outParam2.Value;
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
            taxGroup = newTaxGroupId;
            taxGroupName = newTaxGroupName;
            return saveResult;
        }        

        public SaveResult GetDefaultReceiptTaxGroupId(int? freightTermId, int? locationId, int? entityVendorId, int? entityLocationId, out int? taxGroup, out string taxGroupName)
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
                    "uspICGetDefaultReceiptTaxGroupId @intFreightTermId, @intLocationId, @intEntityVendorId, @intEntityLocationId, @intTaxGroupId OUTPUT, @strTaxGroup OUTPUT"
                    , freightTermIdParam
                    , locationIdParam
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

        public async Task<SearchResult> GetChargeTaxDetails(GetParameter param, int ChargeId, int ReceiptId)
        {
            var query = _db.GetQuery<vyuICGetChargeTaxDetails>()
                    .Where(p => p.intChargeId == ChargeId && p.intInventoryReceiptId == ReceiptId)
                    .Filter(param, true);

            var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
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

            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
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
    }
}
