using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCountGroup : BaseEntity
    {
        public int intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
    }
}
