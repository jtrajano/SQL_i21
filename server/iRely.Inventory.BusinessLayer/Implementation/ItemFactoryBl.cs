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
    public class ItemFactoryBl : BusinessLayer<tblICItemFactory>, IItemFactoryBl 
    {
        #region Constructor
        public ItemFactoryBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemFactory>()
               .Include(p => p.tblSMCompanyLocation)
               .Select(p => new ItemFactoryVM
               {
                   intItemFactoryId = p.intItemFactoryId,
                   intItemId = p.intItemId,
                   intFactoryId = p.intFactoryId,
                   ysnDefault = p.ysnDefault,
                   intSort = p.intSort,
                   strLocationName = p.tblSMCompanyLocation.strLocationName,
               })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemFactoryId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchItemFactoryManufacturingCells(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemFactoryManufacturingCell>()
                           .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemFactoryManufacturingCellId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

    }

    public class ItemOwnerBl : BusinessLayer<tblICItemOwner>, IItemOwnerBl
    {
        #region Constructor
        public ItemOwnerBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

    }
}
