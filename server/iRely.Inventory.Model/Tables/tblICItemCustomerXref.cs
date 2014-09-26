using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemCustomerXref : BaseEntity
    {
        public int intItemCustomerXrefId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strStoreName { get; set; }
        public int intCustomerId { get; set; }
        public string strCustomerProduct { get; set; }
        public string strProductDescription { get; set; }
        public string strPickTicketNotes { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
