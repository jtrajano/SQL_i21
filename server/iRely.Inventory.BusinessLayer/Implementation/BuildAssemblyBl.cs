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
    public class BuildAssemblyBl : BusinessLayer<tblICBuildAssembly>, IBuildAssemblyBl 
    {
        #region Constructor
        public BuildAssemblyBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICBuildAssembly>()
                .Include(p => p.tblICItem)
                .Include(p => p.tblICItemUOM.tblICUnitMeasure)
                .Include(p => p.tblSMCompanyLocation)
                .Include(p => p.tblSMCompanyLocationSubLocation)
                .Select(p => new BuildAssemblyVM
                {
                    intBuildAssemblyId = p.intBuildAssemblyId,
                    dtmBuildDate = p.dtmBuildDate,
                    intItemId = p.intItemId,
                    strItemNo = p.tblICItem.strItemNo,
                    strBuildNo = p.strBuildNo,
                    intLocationId = p.intLocationId,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    intSubLocationId = p.intSubLocationId,
                    strSubLocationName = p.tblSMCompanyLocationSubLocation.strSubLocationName,
                    intItemUOMId = p.intItemUOMId,
                    strItemUOM = p.tblICItemUOM.tblICUnitMeasure.strUnitMeasure,
                    strDescription = p.strDescription
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intBuildAssemblyId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICBuildAssembly entity)
        {
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            entity.strBuildNo = db.GetStartingNumber((int)Common.StartingNumber.BuildAssembly, entity.intLocationId);
            entity.intCreatedUserId = iRely.Common.Security.GetUserId();
            entity.intEntityId = iRely.Common.Security.GetEntityId();
            base.Add(entity);
        }

        public SaveResult PostTransaction(Common.Posting_RequestModel Assembly, bool isRecap)
        {
            // Save the record first 
            var result = _db.Save(false);

            if (result.HasError)
            {
                return result;
            }

            // Post the Adjustment transaction 
            var postResult = new SaveResult();
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                if (Assembly.isPost)
                {
                    db.PostBuildAssembly(isRecap, Assembly.strTransactionId, iRely.Common.Security.GetEntityId());
                }
                else
                {
                    db.UnPostBuildAssembly(isRecap, Assembly.strTransactionId, iRely.Common.Security.GetEntityId());
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
