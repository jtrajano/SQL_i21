using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemSubLocations
    {
        public int intId { get; set; }
        public string strItemNo { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public int intItemLocationId { get; set; }
        public int intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intCountryId { get; set; }
    }
}
