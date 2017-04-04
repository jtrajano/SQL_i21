using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IStorageLocationBl : IBusinessLayer<tblICStorageLocation>
    {
        Task<SearchResult> SearchStorageBins(GetParameter param);
        Task<SearchResult> GetSubLocationBins(GetParameter param);
        Task<SearchResult> SearchSubLocationBinDetails(GetParameter param);
        Task<SearchResult> SearchStorageBinDetails(GetParameter param);
        Task<SearchResult> GetStorageBinMeasurementReading(GetParameter param, int intStorageLocationId);
        StorageLocationBl.DuplicateStorageLocationSaveResult DuplicateStorageLocation(int intStorageLocationId);
    }
}
