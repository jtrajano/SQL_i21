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
    public class InventoryCountBl : BusinessLayer<tblICInventoryCount>, IInventoryCountBl 
    {
        #region Constructor
        public InventoryCountBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryCount>()
                .Filter(param, true);
            var data = await query.Execute(param, "intInventoryCountId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override void Add(tblICInventoryCount entity)
        {
            entity.strCountNo = Common.GetStartingNumber(Common.StartingNumber.InventoryCount);
            base.Add(entity);
        }

        public async Task<SearchResult> GetCountSheets(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCountSheet>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryCountDetailId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public SaveResult LockInventory(int InventoryCountId)
        {
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                db.LockInventory(InventoryCountId);
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
