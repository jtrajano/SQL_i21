using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICLotStatus : BaseEntity
    {
        public int intLotStatusId { get; set; }
        public string strSecondaryStatus { get; set; }
        public string strDescription { get; set; }
        public string strPrimaryStatus { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
    }
}
