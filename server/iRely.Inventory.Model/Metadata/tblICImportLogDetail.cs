using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICImportLogDetail : BaseEntity
    {
        public int intImportLogDetailId { get; set; }
        public int intImportLogId { get; set; }
        public int? intRecordNo { get; set; }
        public string strType { get; set; }
        public string strField { get; set; }
        public string strValue { get; set; }
        public string strMessage { get; set; }
        public string strStatus { get; set; }
        public string strAction { get; set; }

        public tblICImportLog tblICImportLog { get; set; }
    }
}
