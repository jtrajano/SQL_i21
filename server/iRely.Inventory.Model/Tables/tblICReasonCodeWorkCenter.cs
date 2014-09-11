using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICReasonCodeWorkCenter : BaseEntity
    {
        public int intReasonCodeWorkCenterId { get; set; }
        public int intReasonCodeId { get; set; }
        public string strWorkCenterId { get; set; }
        public int intSort { get; set; }
    }
}
