using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class CommodityBl : BusinessLayer<tblICCommodity>, ICommodityBl 
    {
        #region Constructor
        public CommodityBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodity>()
                .Filter(param, true);
            var data = await query.Execute(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override async Task<BusinessResult<tblICCommodity>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICCommodity_strCommodityCode'"))
                {
                    msg = "Commodity Code must be unique.";
                }
            }

            return new BusinessResult<tblICCommodity>()
            {
                success = !result.HasError,
                message = new MessageResult()
                {
                    statusText = msg,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            };
        }

        /// <summary>
        /// Get Compact version of Commodity Details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetCompactCommodities(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodity>()
                .Include("tblICCommodityUnitMeasures.tblICUnitMeasure")                
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
