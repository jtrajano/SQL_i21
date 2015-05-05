using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICStatus : BaseEntity
    {
        public int intStatusId { get; set; }
        public string strStatus { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICInventoryTransfer> tblICInventoryTransfers { get; set; }
    }
}
