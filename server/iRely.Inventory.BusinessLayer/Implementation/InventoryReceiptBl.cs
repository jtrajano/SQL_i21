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

        public override async Task<BusinessResult<tblICInventoryReceipt>> SaveAsync(bool continueOnConflict)
        {
            SaveResult result = new SaveResult();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    int? ReceiptId = null;
                    bool ysnDeleted = false;
                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        ReceiptId = receipt.intInventoryReceiptId;
                        if (receipt.strReceiptType == "Purchase Order")
                        {
                            var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
                            var openStatus = new SqlParameter("ysnOpenStatus", true);
                            _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo, @ysnOpenStatus", idParameter, openStatus);
                        }
                    }
                    var changedReceipts = _db.ContextManager.ChangeTracker.Entries<tblICInventoryReceipt>().Where(p => p.State == EntityState.Deleted).ToList();
                    foreach (var receipt in changedReceipts)
                    {
                        ReceiptId = receipt.Entity.intInventoryReceiptId;
                        ysnDeleted = true;
                        if (receipt.Entity.strReceiptType == "Purchase Order")
                        {
                            var idParameter = new SqlParameter("intReceiptNo", receipt.Entity.intInventoryReceiptId);
                            var openStatus = new SqlParameter("ysnOpenStatus", true);
                            _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo, @ysnOpenStatus", idParameter, openStatus);
                        }
                    }

                    _db.ContextManager.Database.ExecuteSqlCommand("uspICLogTransactionDetail @TransactionType, @TransactionId", new SqlParameter("TransactionType", 1), new SqlParameter("TransactionId", ReceiptId));

                    result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);

                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        ReceiptId = receipt.intInventoryReceiptId;
                        if (receipt.strReceiptType == "Purchase Order")
                        {
                            var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
                            _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo", idParameter);
                        }
                    }

                    var userId = DefaultUserId;
                    _db.ContextManager.Database.ExecuteSqlCommand("uspICInventoryReceiptAfterSave @ReceiptId, @ForDelete, @UserId", new SqlParameter("ReceiptId", ReceiptId), new SqlParameter("ForDelete", ysnDeleted), new SqlParameter("UserId", userId));
                                        
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
                    transaction.Rollback();
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
                    transaction.Rollback();
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
            var data = await query.ExecuteProjection(param, "intInventoryReceiptId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
