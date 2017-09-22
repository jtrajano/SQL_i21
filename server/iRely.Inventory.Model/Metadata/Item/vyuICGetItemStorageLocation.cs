using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStorageLocation : BaseEntity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public int intSubLocationId { get; set; }
        public int intLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public string strStorageLocationDescription { get; set; }
    }
}
