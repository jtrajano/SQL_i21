using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICM2MComputation : BaseEntity
    {
        public int intM2MComputationId { get; set; }
        public string strM2MComputation { get; set; }

        public ICollection<tblICItem> tblICItems { get; set; }
    }
}
