using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Linq.Expressions;
using System.Web;

using iRely.Common;
using iRely.Inventory.Model;
using IdeaBlade.Core;
using IdeaBlade.Linq;

namespace iRely.Inventory.BRL
{
    public partial class Receipt : IDisposable
    {
        private Repository _db;

        public Receipt()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<vyuReciepts> GetSearchQuery()
        {
            return _db.GetQuery<tblICInventoryReceipt>()
                .Include(p => p.vyuAPVendor)
                .Include(p => p.tblSMCompanyLocation)
                .Select(p => new vyuReciepts {
                    intInventoryReceiptId = p.intInventoryReceiptId,
                    strReceiptNumber = p.strReceiptNumber,
                    strReceiptType = p.strReceiptType,
                    strVendorName = p.vyuAPVendor.strName,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    dtmReceiptDate = p.dtmReceiptDate,
                    ysnPosted = p.ysnPosted
                });

        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<vyuReciepts, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<vyuReciepts, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICInventoryReceipt> GetReceipts(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<vyuReciepts, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICInventoryReceipt>()
                .Include(p => p.tblICInventoryReceiptInspections)
                .Include(p => p.vyuAPVendor)
                .Include(p=> p.tblSMFreightTerm)
                .Include(p => p.tblSMCompanyLocation)
                .Include("tblICInventoryReceiptItems.tblICItem")
                .Include("tblICInventoryReceiptItems.tblICItemUOM.tblICUnitMeasure")
                .Include("tblICInventoryReceiptItems.vyuICGetReceiptItemSource")
                .Include("tblICInventoryReceiptItems.tblICInventoryReceiptItemLots.tblICLot")
                .Include("tblICInventoryReceiptItems.tblICInventoryReceiptItemLots.tblICItemUOM.tblICUnitMeasure")
                .Include("tblICInventoryReceiptItems.tblICInventoryReceiptItemLots.tblICStorageLocation")
                .Include("tblICInventoryReceiptItems.WeightUOM.tblICUnitMeasure")
                .Include("tblICInventoryReceiptItems.tblICInventoryReceiptItemTaxes")
                .Include("tblICInventoryReceiptItems.tblSMCompanyLocationSubLocation")
                .Include("tblICInventoryReceiptInspections.tblMFQAProperty")
                .Where(w => query.Where(predicate).Any(a => a.intInventoryReceiptId == w.intInventoryReceiptId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddReceipt(tblICInventoryReceipt receipt)
        {
            receipt.strReceiptNumber = Common.GetStartingNumber(Common.StartingNumber.InventoryReceipt);
            receipt.intCreatedUserId = iRely.Common.Security.GetUserId();
            receipt.intEntityId = iRely.Common.Security.GetEntityId();
            _db.AddNew<tblICInventoryReceipt>(receipt);
        }

        public void UpdateReceipt(tblICInventoryReceipt receipt)
        {
            _db.UpdateBatch<tblICInventoryReceipt>(receipt);
        }

        public void DeleteReceipt(tblICInventoryReceipt receipt)
        {
            _db.Delete<tblICInventoryReceipt>(receipt);
        }

        public SaveResult Save(bool continueOnConflict)
        {
            SaveResult saveResult = new SaveResult();

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

                    saveResult = _db.Save(false);

                    foreach (var receipt in _db.ContextManager.Set<tblICInventoryReceipt>().Local)
                    {
                        if (receipt.strReceiptType == "Purchase Order")
                        {
                            var idParameter = new SqlParameter("intReceiptNo", receipt.intInventoryReceiptId);
                            _db.ContextManager.Database.ExecuteSqlCommand("uspICUpdatePOStatusOnReceiptSave @intReceiptNo", idParameter);
                        }
                    }

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
                    var userId = new SqlParameter("@intUserId", iRely.Common.Security.GetUserId());
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
        
        public void Dispose()
        {
            _db.Dispose();
        }
    }
}
