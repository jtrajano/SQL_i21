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
    public class StorageMeasurementReadingBl : BusinessLayer<tblICStorageMeasurementReading>, IStorageMeasurementReadingBl 
    {
        #region Constructor
        public StorageMeasurementReadingBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
        
        public override async Task<BusinessResult<tblICStorageMeasurementReading>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICStorageMeasurementReadingConversion'"))
                {
                    msg = "Storage Reading Measurement Conversions must be unique.";
                }
            }

            return new BusinessResult<tblICStorageMeasurementReading>()
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

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICStorageMeasurementReading>()
               .Include(p => p.tblSMCompanyLocation)
               .Select(p => new StorageMeasurementReadingVM
               {
                    intStorageMeasurementReadingId = p.intStorageMeasurementReadingId,
                    intLocationId = p.intLocationId,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    dtmDate = p.dtmDate,
                    strReadingNo = p.strReadingNo
               })
                .Filter(param, true);

            var sorts = new List<SearchSort>();

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strreadingno" && ps.direction == "ASC")
                {
                    sorts.Add(new SearchSort() { property = "intStorageMeasurementReadingId", direction = "ASC" });
                }

                else if (ps.property.ToLower() == "strreadingno" && ps.direction == "DESC")
                {
                    sorts.Add(new SearchSort() { property = "intStorageMeasurementReadingId", direction = "DESC" });
                }
            }

            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intStorageMeasurementReadingId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override void Add(tblICStorageMeasurementReading entity)
        {
            var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
            
            entity.strReadingNo = db.GetStartingNumber((int)Common.StartingNumber.StorageMeasurementReading, entity.intLocationId);
            base.Add(entity);
        }
    }
}
