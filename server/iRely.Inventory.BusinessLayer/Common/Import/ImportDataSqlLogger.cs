using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public sealed class ImportDataSqlLogger
    {
        private static ImportDataSqlLogger _instance;
        private DbContext _context;

        private ImportDataSqlLogger(DbContext context) { _context = context; }

        public static ImportDataSqlLogger GetInstance(DbContext context)
        {
            if (_instance == null)
                _instance = new ImportDataSqlLogger(context);
            return _instance;
        }

        public async Task<int> WriteLogs(ImportDataResult result)
        {
            var log = new tblICImportLog()
            {
                strDescription = result.Description.Length > 1000 ? result.Description.Substring(0, 999) : result.Description,
                intTotalRows = result.TotalRows,
                intRowsImported = result.RowsImported,
                intTotalErrors = result.Errors,
                intTotalWarnings = result.Warnings,
                dblTimeSpentInSeconds = (decimal)result.TimeSpentInSeconds,
                intUserEntityId = iRely.Common.Security.GetEntityId(),
                strFileName = GlobalSettings.Instance.FileName,
                strFileType = GlobalSettings.Instance.FileType,
                strType = GlobalSettings.Instance.ImportType,
                dtmDateImported = DateTime.UtcNow,
                ysnAllowDuplicates = GlobalSettings.Instance.AllowDuplicates,
                ysnAllowOverwriteOnImport = GlobalSettings.Instance.AllowOverwriteOnImport,
                ysnContinueOnFailedImports = GlobalSettings.Instance.ContinueOnFailedImports,
                strLineOfBusiness = GlobalSettings.Instance.LineOfBusiness,
                tblICImportLogDetails = new List<tblICImportLogDetail>()
            };

            foreach(ImportDataMessage idm in result.Messages)
            {
                var logDetail = new tblICImportLogDetail()
                {
                    intRecordNo = idm.Row,
                    strField = idm.Column.Length > 50 ? $"{idm.Column.Substring(0, 45)}..." : idm.Column,
                    strValue = idm.Value,
                    strMessage = idm.Message,
                    strStatus = idm.Status,
                    strAction = idm.Action,
                    strType = idm.Type,
                    tblICImportLog = log
                };
                log.tblICImportLogDetails.Add(logDetail);
            }

            _context.Set<tblICImportLog>().Add(log);
            _context.Set<tblICImportLogDetail>().AddRange(log.tblICImportLogDetails);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (System.Data.Entity.Validation.DbEntityValidationException dbEx)
            {
                Exception raise = dbEx;
                foreach (var validationErrors in dbEx.EntityValidationErrors)
                {
                    foreach (var validationError in validationErrors.ValidationErrors)
                    {
                        string message = string.Format("{0}:{1}",
                            validationErrors.Entry.Entity.ToString(),
                            validationError.ErrorMessage);
                        // raise a new exception nesting  
                        // the current instance as InnerException  
                        raise = new InvalidOperationException(message, raise);
                    }
                }
                throw raise;
            }
            return log.intImportLogId;
        }
    }
}
