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
            var data = await query.ExecuteProjection(param, "intStorageMeasurementReadingId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override void Add(tblICStorageMeasurementReading entity)
        {
            entity.strReadingNo = Common.GetStartingNumber(Common.StartingNumber.StorageMeasurementReading);
            base.Add(entity);
        }
    }
}
