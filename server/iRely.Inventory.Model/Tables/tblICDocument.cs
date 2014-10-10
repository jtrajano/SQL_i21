using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICDocument : BaseEntity
    {
        public int intDocumentId { get; set; }
        public string strDocumentName { get; set; }
        public string strDescription { get; set; }
        public int? intCommodityId { get; set; }
        public bool ysnStandard { get; set; }

        public virtual ICollection<tblICItemContractDocument> tblICItemContractDocuments { get; set; }
    }
}
