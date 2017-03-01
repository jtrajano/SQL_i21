using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICItemSubLocation : BaseEntity
    {
        public int intItemSubLocationId { get; set; }
        public int intSubLocationId { get; set; }
        public int intItemLocationId { get; set; }

        public tblICItemLocation tblICItemLocation { get; set; }
    }
}
