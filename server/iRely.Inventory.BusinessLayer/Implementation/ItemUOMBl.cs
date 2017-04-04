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
    public class ItemUOMBl : BusinessLayer<tblICItemUOM>, IItemUOMBl 
    {
        #region Constructor
        public ItemUOMBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemUOM>()
                .Include(p => p.tblICUnitMeasure)
                .Include(p => p.WeightUOM)
                .Select(p => new ItemUOMVM
                {
                    intItemUOMId = p.intItemUOMId,
                    intItemId = p.intItemId,
                    intUnitMeasureId = p.intUnitMeasureId,
                    dblUnitQty = p.dblUnitQty,
                    dblWeight = p.dblWeight,
                    intWeightUOMId = p.intWeightUOMId,
                    strUpcCode = p.strUpcCode,
                    strLongUPCCode = p.strLongUPCCode,
                    ysnStockUnit = p.ysnStockUnit,
                    ysnAllowPurchase = p.ysnAllowPurchase,
                    ysnAllowSale = p.ysnAllowSale,
                    strUnitMeasure = p.tblICUnitMeasure.strUnitMeasure,
                    strUnitType = p.tblICUnitMeasure.strUnitType,
                    strWeightUOM = p.WeightUOM.strUnitMeasure
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchWeightUOMs(GetParameter param)
        {
            var query = (
                    from ItemUOM in _db.GetQuery<tblICItemUOM>()
                    join UOM in _db.GetQuery<tblICUnitMeasure>()
                        on ItemUOM.intUnitMeasureId equals UOM.intUnitMeasureId
                    where UOM.strUnitType == "Weight"
                    select new WeightUOMVm
                    {
                        intItemUOMId = ItemUOM.intItemUOMId,
                        strUnitMeasure = UOM.strUnitMeasure,
                        strUnitType = UOM.strUnitType,
                        intItemId = ItemUOM.intItemId,
                        dblUnitQty = ItemUOM.dblUnitQty ?? 0,
                        ysnStockUnit = ItemUOM.ysnStockUnit,
                        ysnAllowPurchase = ItemUOM.ysnAllowPurchase,
                        ysnAllowSale = ItemUOM.ysnAllowSale
                    }
                )
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemUOMId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchWeightVolumeUOMs(GetParameter param)
        {
            var query = (
                    from ItemUOM in _db.GetQuery<tblICItemUOM>()
                    join UOM in _db.GetQuery<tblICUnitMeasure>()
                        on ItemUOM.intUnitMeasureId equals UOM.intUnitMeasureId
                    where UOM.strUnitType == "Weight" || UOM.strUnitType == "Volume"
                    select new WeightUOMVm
                    {
                        intItemUOMId = ItemUOM.intItemUOMId,
                        strUnitMeasure = UOM.strUnitMeasure,
                        strUnitType = UOM.strUnitType,
                        intItemId = ItemUOM.intItemId,
                        dblUnitQty = ItemUOM.dblUnitQty ?? 0,
                        ysnStockUnit = ItemUOM.ysnStockUnit,
                        ysnAllowPurchase = ItemUOM.ysnAllowPurchase,
                        ysnAllowSale = ItemUOM.ysnAllowSale
                    }
                )
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemUOMId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchUOMs(GetParameter param)
        {
            var query = _db.GetQuery<vyuICItemUOM>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "strItemNo", "ASC").ToListAsync();
            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
