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

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICInventoryReceipt>()
                .Include(p => p.vyuAPVendor)
                .Include(p => p.tblSMCompanyLocation)
                .Select(p => new RecieptVM
                {
                    intInventoryReceiptId = p.intInventoryReceiptId,
                    strReceiptNumber = p.strReceiptNumber,
                    strReceiptType = p.strReceiptType,
                    strVendorName = p.vyuAPVendor.strName,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    dtmReceiptDate = p.dtmReceiptDate,
                    ysnPosted = p.ysnPosted ?? false
                })
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

        public override async Task<BusinessResult<tblICInventoryReceipt>> SaveAsync(bool continueOnConflict)
        {
            SaveResult result = new SaveResult();

            using (var transaction = _db.ContextManager.Database.BeginTransaction())
            {
                var connection = _db.ContextManager.Database.Connection;
                try
                {
                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
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
                        if (receipt.Entity.strReceiptType == "Purchase Order")
                        {
                            var idParameter = new SqlParameter("intReceiptNo", receipt.Entity.intInventoryReceiptId);
                            var openStatus = new SqlParameter("ysnOpenStatus", true);
                            _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo, @ysnOpenStatus", idParameter, openStatus);
                        }
                    }

                    result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);

                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        if (receipt.strReceiptType == "Purchase Order")
                        {
                            var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
                            _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo", idParameter);
                        }
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
                    saveResult.BaseException = ex;
                    saveResult.Exception = new ServerException(ex);
                    saveResult.HasError = true;
                    //transaction.Rollback();
                }
            }
            newBill = newBillId;
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
                    db.PostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetUserId(), iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnpostInventoryReceipt(isRecap, receipt.strTransactionId, iRely.Common.Security.GetUserId(), iRely.Common.Security.GetEntityId());
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
