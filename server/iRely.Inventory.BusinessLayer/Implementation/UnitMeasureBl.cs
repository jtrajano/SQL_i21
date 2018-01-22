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
    public class UnitMeasureBl : BusinessLayer<tblICUnitMeasure>, IUnitMeasureBl 
    {
        #region Constructor
        public UnitMeasureBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<BusinessResult<tblICUnitMeasure>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICUnitMeasure_strUnitMeasure'"))
                {
                    msg = "Unit Measure must be unique.";
                }
            }

            return new BusinessResult<tblICUnitMeasure>()
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

        public async Task<SearchResult> SearchPackedUOMs(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetPackedUOM>()
                .Where(p => p.strUnitType == "Packed")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intUnitMeasureId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetAreaLengthUOM(GetParameter param)
        {
            var query = _db.GetQuery<tblICUnitMeasure>().Where(p => p.strUnitType == "Area" || p.strUnitType == "Length")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intUnitMeasureId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetQuantityVolumeWeightPackedAreaUOM(GetParameter param)
        {
            var query = _db.GetQuery<tblICUnitMeasure>().Where(p => p.strUnitType == "Quantity" || p.strUnitType == "Volume" || p.strUnitType == "Weight" || p.strUnitType == "Packed" || p.strUnitType == "Area")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intUnitMeasureId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetTimeUOM(GetParameter param)
        {
            var query = _db.GetQuery<tblICUnitMeasure>().Where(p => p.strUnitType == "Time")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intUnitMeasureId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetUOMConversion(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetUOMConversion>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intUnitMeasureConversionId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetValidTargetUOM(GetParameter param)
        {
            // Create a new filter based on the supplied Unit type. 
            string strUnitType = string.Empty;

            // Find the first unit type filter. 
            foreach (var f in param.filter)
            {                
                if (f.c.ToLower() == "strunittype")
                {
                    strUnitType = f.v;
                    break; 
                }
            }

            // Remove the Unit Type filter and create a new filter
            var newFilter = new List<SearchFilter>();            
            foreach (var f in param.filter)
            {
                if (f.c.ToLower() != "strunittype")
                {
                    newFilter.Add(
                        new SearchFilter()
                        {
                            c = f.c,
                            v = f.v,
                            cj = f.cj,
                            co = f.co                           
                        }
                    ); 
                }
            }
            param.filter = newFilter;

            switch (strUnitType.ToLower()) {
                case "area":
                case "length":
                    return await GetAreaLengthUOM(param);
                case "quantity":
                case "volume":
                case "weight":
                    return await GetQuantityVolumeWeightPackedAreaUOM(param);
                case "time":
                    return await GetTimeUOM(param);
                default:
                    return await Search(param); 
            }; 
        }
    }
}
