using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using System.Data.Entity;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportLogBl : BusinessLayer<tblICImportLog>, IImportLogBl
    {
        public ImportLogBl(IInventoryRepository db) : base(db)
        {
            
        }

        public async Task<SearchResult> SearchImportLogs(GetParameter param)
        {
            var username = Security.GetUserName();
            var query = from logs in _db.ContextManager.Set<tblICImportLog>().Filter(param, true)
                        join users in _db.ContextManager.Set<tblSMUserSecurity>() on logs.intUserEntityId equals users.intEntityId into gj
                        from x in gj.DefaultIfEmpty()
                        select new
                        {
                            logs.intImportLogId,
                            logs.strDescription,
                            logs.intTotalRows,
                            logs.intRowsImported,
                            logs.intRowsUpdated,
                            logs.intTotalErrors,
                            logs.intTotalWarnings,
                            logs.dblTimeSpentInSeconds,
                            logs.intUserEntityId,
                            strUsername = x.strFullName,
                            logs.strType,
                            logs.strFileType,
                            logs.strFileName,
                            logs.dtmDateImported,
                            logs.ysnAllowDuplicates,
                            logs.ysnAllowOverwriteOnImport,
                            logs.ysnContinueOnFailedImports,
                            logs.strLineOfBusiness
                        };
            var data = await query.ExecuteProjection(param, "dtmDateImported", "DESC").ToListAsync(param.cancellationToken);
            var response = new SearchResult()
            {
                data = data.AsQueryable(),
                success = true,
                total = await query.CountAsync(param.cancellationToken)
            };
            return response;
        }
    }
}
