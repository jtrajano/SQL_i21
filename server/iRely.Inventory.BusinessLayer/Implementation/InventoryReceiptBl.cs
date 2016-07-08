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
    public class InventoryReceiptBl : BusinessLayer<tblICInventoryReceipt>, IInventoryReceiptBl 
    {
        #region Constructor
        public InventoryReceiptBl(IRepository db) : base(db)
        {
            _db = db;
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
                total = await query.CountAsync()
            };
        }

        public override void Add(tblICInventoryReceipt entity)
        {
            entity.strReceiptNumber = Common.GetStartingNumber(Common.StartingNumber.InventoryReceipt);
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
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICLogTransactionDetail @TransactionType, @TransactionId", 
                            new SqlParameter("TransactionType", 1),
                            new SqlParameter("TransactionId", receipt.intInventoryReceiptId)
                        );
                    }

                    // Log the original data from the deleted receipts.
                    foreach (var receipt in deletedReceipts)
                    {
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICLogTransactionDetail @TransactionType, @TransactionId",
                            new SqlParameter("TransactionType", 1),
                            new SqlParameter("TransactionId", receipt.Entity.intInventoryReceiptId)
                        );

                        // Update the PO or Scale status from deleted shipment records.
                        // Usually, deleted records will "open" the status of the PO or Scale Ticket.
                        // Call this sp before the _db.SaveAsync because uspICUpdateStatusOnShipmentSave is not reading it from the log table. 
                        _db.ContextManager.Database.ExecuteSqlCommand(
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
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId",
                            new SqlParameter("ReceiptId", receipt.Entity.intInventoryReceiptId), 
                            new SqlParameter("ForDelete", true), 
                            new SqlParameter("UserId", DefaultUserId)
                        );
                    }                   

                    // Process the newly saved data. 
                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICUpdateStatusOnReceiptSave @intReceiptNo"
                            , new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId)
                        );

                        _db.ContextManager.Database.ExecuteSqlCommand(
                            "uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId",
                            new SqlParameter("ReceiptId", receipt.intInventoryReceiptId), 
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


        public SaveResult ProcessBill(int receiptId, out int? newBill)
        {
            SaveResult saveResult = new SaveResult();
            int? newBillId = null;

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
                    _db.ContextManager.Database.ExecuteSqlCommand("uspICProcessToBill @intReceiptId, @intUserId, @intBillId OUTPUT", idParameter, userId, outParam);
                    newBillId = (int)outParam.Value;
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

        public SaveResult PostTransaction(Common.Posting_RequestModel receipt, bool isRecap)
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
                if (receipt.isPost)
                {
                    db.PostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnpostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetEntityId());
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

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
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
                total = await query.CountAsync()
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
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetAddOrders(GetParameter param, int VendorId, string ReceiptType, int SourceType, int CurrencyId)
        {
            if (ReceiptType == "Transfer Order")
            {
                var query = _db.GetQuery<vyuICGetReceiptAddOrder>()
                    .Where(p => p.strReceiptType == ReceiptType && p.intSourceType == SourceType && p.intCurrencyId == CurrencyId)
                    .Filter(param, true);

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync()
                };
            }

            else {
                var query = _db.GetQuery<vyuICGetReceiptAddOrder>()
                                .Where(p => p.intEntityVendorId == VendorId && p.strReceiptType == ReceiptType && p.intSourceType == SourceType && p.intCurrencyId == CurrencyId)
                                .Filter(param, true);

                var data = await query.ExecuteProjection(param, "intKey").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync()
                };
            }
        }

        public async Task<SearchResult> GetReceiptVouchers(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptVoucher>()
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strbillid" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intBillId", direction = "ASC" });
                    sorts.Add(new SearchSort() { property = "intInventoryReceiptId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strbillid" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intBillId", direction = "DESC" });
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
                summaryData = query.ToAggregate(param.aggregates)
            };
        }
    }
}
