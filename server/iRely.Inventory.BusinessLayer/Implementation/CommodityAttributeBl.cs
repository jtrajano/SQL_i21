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
    public class CommodityAttributeBl : BusinessLayer<tblICCommodityAttribute>, ICommodityAttributeBl
    {
        #region Constructor
        public CommodityAttributeBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchOriginAttributes(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodityOrigin>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchProductTypeAttributes(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodityProductType>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchRegionAttributes(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodityRegion>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchSeasonAttributes(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommoditySeason>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchClassAttributes(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodityClassVariant>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchProductLineAttributes(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodityProductLine>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchGradeAttributes(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCommodityGrade>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
