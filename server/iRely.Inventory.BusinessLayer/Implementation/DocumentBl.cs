using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class DocumentBl : BusinessLayer<tblICDocument>, IDocumentBl 
    {
        #region Constructor
        public DocumentBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICDocument>()
                .Select(p => new DocumentVM
                {
                    intDocumentId = p.intDocumentId,
                    strDocumentName = p.strDocumentName,
                    strDescription = p.strDescription,
                    intDocumentType = p.intDocumentType,
                    intCommodityId = p.intCommodityId,
                    strCommodity = p.tblICCommodity.strCommodityCode,
                    ysnStandard = p.ysnStandard,
                    strDocumentType = p.intDocumentType == 1 ? "Contract" : p.intDocumentType == 2 ? "Bill Of Lading" : p.intDocumentType == 3 ? "Container" : ""
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intDocumentId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
