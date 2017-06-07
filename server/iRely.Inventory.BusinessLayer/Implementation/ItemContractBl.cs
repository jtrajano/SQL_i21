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
    public class ItemContractBl : BusinessLayer<tblICItemContract>, IItemContractBl 
    {
        #region Constructor
        public ItemContractBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetContractItem(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemContract>()
                .Include(p => p.tblICItemLocation)
                .Include(p => p.tblSMCountry)
                .Select(p => new ContractItemVM
                {
                    strLocationName = p.tblICItemLocation.vyuICGetItemLocation.strLocationName,
                    intItemContractId = p.intItemContractId,
                    intItemId = p.intItemId,
                    intItemLocationId = p.intItemLocationId,
                    strContractItemNo = p.strContractItemNo,
                    strContractItemName = p.strContractItemName,
                    intCountryId = p.intCountryId,
                    strGrade = p.strGrade,
                    strGradeType = p.strGradeType,
                    strGarden = p.strGarden,
                    dblYieldPercent = p.dblYieldPercent,
                    dblTolerancePercent = p.dblTolerancePercent,
                    dblFranchisePercent = p.dblFranchisePercent,
                    intSort = p.intSort,
                    strCountry = p.tblSMCountry.strCountry,
                    strStatus = p.strStatus,
                    intConcurrencyId = p.intConcurrencyId
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemContractId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetContractDocument(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemContractDocument>()
                .Include(p => p.tblICDocument)
                .Select(p => new ContractDocumentVM
                {
                    intItemContractDocumentId = p.intItemContractDocumentId,
                    intItemContractId = p.intItemContractId,
                    intDocumentId = p.intDocumentId,
                    intSort = p.intSort,
                    strDocumentName = p.tblICDocument.strDocumentName,
                    intConcurrencyId = p.intConcurrencyId
                 })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemContractId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

    }
}
