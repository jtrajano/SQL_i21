using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemContractDocument : BaseEntity
    {
        public int intItemContractDocumentId { get; set; }
        public int intItemContractId { get; set; }
        public int intDocumentId { get; set; }
        public int intSort { get; set; }

        public tblICItemContract tblICItemContract { get; set; }
        public tblICDocument tblICDocument { get; set; }
    }
}
