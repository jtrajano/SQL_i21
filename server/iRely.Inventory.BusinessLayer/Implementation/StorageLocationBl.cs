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
using Newtonsoft.Json;

namespace iRely.Inventory.BusinessLayer
{
    public class StorageLocationBl : BusinessLayer<tblICStorageLocation>, IStorageLocationBl 
    {
        #region Constructor
        public StorageLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<BusinessResult<tblICStorageLocation>> SaveAsync(bool continueOnConflict)
        {
            SaveResult result = new SaveResult();
            string statusText = null; 
            try
            {
                // Validate the modified records if it is okay to change the sub location. 
                var updatedStorageLocations = _db.ContextManager.Set<tblICStorageLocation>().Local;
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                foreach (var record in updatedStorageLocations)
                {
                    await db.ValidateSubLocationChange(record.intStorageLocationId, record.intSubLocationId);
                }

                // Do the Save. 
                result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
                statusText = result.Exception.Message;

                if (result.HasError)
                {
                    if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICStorageLocation_strName'"))
                    {
                        statusText = "Storage Location must be unique per Location and Sub Location.";
                    }
                }
            }
            catch (Exception ex)
            {
                result.BaseException = ex;
                result.Exception = new ServerException(ex);
                result.HasError = true;
                statusText = ex.Message;
            }

            return new BusinessResult<tblICStorageLocation>()
            {
                success = !result.HasError,
                message = new MessageResult()
                {
                    statusText = statusText,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            };
        }

        public async Task<SearchResult> GetStorageUnitStock(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetStorageUnitStock>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "strItemNo", "ASC").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetStorageLocation>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intStorageLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchStorageBins(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetStorageBins>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intStorageLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchSubLocationBins(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetSubLocationBins>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intSubLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        class StorageBin
        {
            public int intStorageLocationId { get; set; }
        }

        class SubLocationBin
        {
            public int intSubLocationId { get; set; }
        }

        public async Task<SearchResult> SearchSubLocationBinDetails(GetParameter param)
        {
            int subLocationId = 0;
            if (param.chartinfo != null)
            {
                ChartInfo chartinfo = param.chartinfo.First();
                if (chartinfo != null)
                {
                    try
                    {
                        SubLocationBin m = JsonConvert.DeserializeObject<SubLocationBin>(chartinfo.data.ToString());
                        subLocationId = m.intSubLocationId;
                    }
                    catch (Exception)
                    {
                        subLocationId = 0;
                    }
                }
            }

            IQueryable<vyuICGetSubLocationBinDetails> query = null;
            if (subLocationId != 0)
            {
                query = _db.GetQuery<vyuICGetSubLocationBinDetails>()
                    .Where(w => w.intSubLocationId == subLocationId)
                    .Filter(param, true);
            }
            else
            {
                query = _db.GetQuery<vyuICGetSubLocationBinDetails>()
                    .Where(w => w.intSubLocationId == subLocationId)
                    .Filter(param, true);
            }

            var data = await query.ExecuteProjection(param, "intItemLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchStorageBinDetails(GetParameter param)
        {
            int storageLocationId = 0;
            if (param.chartinfo != null)
            {
                ChartInfo chartinfo = param.chartinfo.First();
                if (chartinfo != null)
                {
                    try
                    {
                        StorageBin m = JsonConvert.DeserializeObject<StorageBin>(chartinfo.data.ToString());
                        storageLocationId = m.intStorageLocationId;
                    }
                    catch (Exception)
                    {
                        storageLocationId = 0;
                    }
                }
            }

            IQueryable<vyuICGetStorageBinDetails> query = null;
            if (storageLocationId != 0)
            {
                query = _db.GetQuery<vyuICGetStorageBinDetails>()
                    .Where(w => w.intStorageLocationId == storageLocationId)
                    .Filter(param, true);
            }
            else
            {
                query = _db.GetQuery<vyuICGetStorageBinDetails>()
                    .Where(w => w.intStorageLocationId == storageLocationId)
                    .Filter(param, true);
            }

            var data = await query.ExecuteProjection(param, "intItemLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetStorageBinMeasurementReading(GetParameter param, int intStorageLocationId)
        {
            var query = _db.GetQuery<vyuICGetStorageBinMeasurementReading>()
                .Where(w => w.intStorageLocationId == intStorageLocationId)
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public class DuplicateStorageLocationSaveResult : SaveResult
        {
            public int? Id { get; set; }
        }

        public DuplicateStorageLocationSaveResult DuplicateStorageLocation(int intStorageLocationId)
        {
            int? newStorageLocationId = 0;
            var duplicationResult = new DuplicateStorageLocationSaveResult();
            try
            {
                var db = (InventoryEntities)_db.ContextManager;
                newStorageLocationId = db.DuplicateStorageLocation(intStorageLocationId);
                var res = _db.Save(false);
                duplicationResult.Id = newStorageLocationId;
                duplicationResult.HasError = false;
            }
            catch (Exception ex)
            {
                duplicationResult.BaseException = ex;
                duplicationResult.HasError = true;
                duplicationResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return duplicationResult;
        }

        public async Task<SaveResult> ValidateSubLocationChange(int storageLocationId, int? newSubLocationId)
        {
            SaveResult saveResult = new SaveResult();

            // Check if user is allowed to change the sub location within the storage location setup. 
            try
            {
                var db = (Inventory.Model.InventoryEntities)_db.ContextManager;
                await db.ValidateSubLocationChange(storageLocationId, newSubLocationId);
                saveResult.HasError = false;
            }
            catch (Exception ex)
            {
                saveResult.BaseException = ex;
                saveResult.HasError = true;
                saveResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return saveResult;
        }
    }
}
