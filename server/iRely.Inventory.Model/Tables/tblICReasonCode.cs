using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICReasonCode : BaseEntity
    {
        public int intReasonCodeId { get; set; }
        public string strReasonCode { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strLotTransactionType { get; set; }
        public bool ysnDefault { get; set; }
        public bool ysnReduceAvailableTime { get; set; }
        public bool ysnExplanationRequired { get; set; }
        public string strLastUpdatedBy { get; set; }
        public DateTime dtmLastUpdatedOn { get; set; }
    }
}
