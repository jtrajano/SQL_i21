﻿using iRely.Common;
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
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICStorageLocation_strName'"))
                {
                    msg = "Storage Location must be unique per Location and Sub Location.";
                }
            }

            return new BusinessResult<tblICStorageLocation>()
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
            var query = _db.GetQuery<vyuICGetStorageLocation>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intStorageLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetStorageBins(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetStorageBins>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intStorageLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        class StorageBin
        {
            public int intStorageLocationId { get; set; }
        }

        public async Task<SearchResult> GetStorageBinDetails(GetParameter param)
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
                    .Filter(param, true);
            }

            var data = await query.ExecuteProjection(param, "intItemLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
