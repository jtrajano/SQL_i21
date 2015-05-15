using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
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
    public class ItemUOMBl : BusinessLayer<tblICItemUOM>, IItemUOMBl 
    {
        #region Constructor
        public ItemUOMBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetWeightUOMs(GetParameter param)
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
                        intItemId = ItemUOM.intItemId
                    }
                )
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
