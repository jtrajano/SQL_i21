using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICImportLog : BaseEntity
    {
        public int intImportLogId { get; set; }
        [MaxLength]
        public string strDescription { get; set; }
        public string strType { get; set; }
        public string strFileType { get; set; }
        public int? intTotalRows { get; set; }
        public int? intRowsImported { get; set; }
        public int? intTotalErrors { get; set; }
        public int? intTotalWarnings { get; set; }
        public decimal? dblTimeSpentInSeconds { get; set; }
        public int? intUserEntityId { get; set; }
        public string strFileName { get; set; }
        public DateTime dtmDateImported { get; set; }
        public bool? ysnAllowDuplicates { get; set; }
        public bool? ysnAllowOverwriteOnImport { get; set; }
        public string strLineOfBusiness { get; set; }
        public bool? ysnContinueOnFailedImports { get; set; }
        public ICollection<tblICImportLogDetail> tblICImportLogDetails { get; set; }
    }
}
