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
        public int strReasonCode { get; set; }
        public int strType { get; set; }
        public int strDescription { get; set; }
        public int strLotTransactionType { get; set; }
        public bool ysnDefault { get; set; }
        public bool ysnReduceAvailableTime { get; set; }
        public bool ysnExplanationRequired { get; set; }
        public int strLastUpdatedBy { get; set; }
        public DateTime dtmLastUpdatedOn { get; set; }
    }
}
