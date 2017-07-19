using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICItemSubLocations
    {
        public int intItemSubLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intConcurrencyId { get; set; }

    }
}
