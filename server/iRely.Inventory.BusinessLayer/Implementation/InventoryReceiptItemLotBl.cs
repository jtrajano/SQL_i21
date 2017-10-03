﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryReceiptItemLotBl : BusinessLayer<tblICInventoryReceiptItemLot>, IInventoryReceiptItemLotBl
    {
        public InventoryReceiptItemLotBl(IInventoryRepository db)
            : base(db)
        {
            _db = db;
            _db.ContextManager.Database.CommandTimeout = 180000;
        }

        public async Task<SearchResult> SearchLots(GetParameter param)
        {
            //var query = _db.GetQuery<tblICInventoryReceiptItemLot>()
            //    .Include(p => p.tblICInventoryReceiptItem.vyuICInventoryReceiptItemLookUp)
            //    .Include(p => p.vyuICGetInventoryReceiptItemLot)
            //    .Filter(param, true);
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemLot2>()
                //.Include(p => p.tblICInventoryReceiptItem.vyuICInventoryReceiptItemLookUp)
                //.Include(p => p.vyuICGetInventoryReceiptItemLot)
                .Filter(param, true);

            var data = await query.Execute(param, "intInventoryReceiptItemLotId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetLots(int? intInventoryReceiptItemId)
        {
            //var query = _db.GetQuery<tblICInventoryReceiptItemLot>()
            //    .Include(p => p.tblICInventoryReceiptItem.vyuICInventoryReceiptItemLookUp)
            //    .Include(p => p.vyuICGetInventoryReceiptItemLot)
            //    .Filter(param, true);
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemLot2>()
                //.Include(p => p.tblICInventoryReceiptItem.vyuICInventoryReceiptItemLookUp)
                //.Include(p => p.vyuICGetInventoryReceiptItemLot)
                //.Filter(param, true);
                .Where(w => w.intInventoryReceiptItemId == intInventoryReceiptItemId);

            //var data = await query.Execute(param, "intInventoryReceiptItemLotId").ToListAsync();

            var data = await query.ToListAsync(); 

            return new SearchResult()
            {
                data = data.AsQueryable(), 
                total = await query.CountAsync()
                //summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
