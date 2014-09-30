using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemAccount : BaseEntity
    {
        public int intItemAccountId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strAccountDescription { get; set; }
        public int intAccountId { get; set; }
        public int intProfitCenterId { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
