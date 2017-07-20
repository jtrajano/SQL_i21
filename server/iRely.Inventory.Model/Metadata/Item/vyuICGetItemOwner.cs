using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemOwner
    {
        public int intItemOwnerId { get; set; }
        public int intItemId { get; set; }
        public int intOwnerId { get; set; }
        public string strName { get; set; }
        public string strCustomerNumber { get; set; }
        public string strItemNo { get; set; }
    }
}
