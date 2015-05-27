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
    public class ItemFactoryBl : BusinessLayer<tblICItemFactory>, IItemFactoryBl 
    {
        #region Constructor
        public ItemFactoryBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetItemFactoryManufacturingCells(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemFactoryManufacturingCell>()
                           .Include(p => p.tblICManufacturingCell)
                           .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
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
