using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Linq.Expressions;
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
        public int? intDocumentType { get; set; }
        public int? intCommodityId { get; set; }
        public bool ysnStandard { get; set; }
        public int? intCertificationId { get; set; }
        public int? intOriginal { get; set; }
        public int? intCopies { get; set; }

        public ICollection<tblICItemContractDocument> tblICItemContractDocuments { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
        public tblICCertification tblICCertification { get; set; }
    }

    public class DocumentVM
    {
        public int intDocumentId { get; set; }
        public string strDocumentName { get; set; }
        public string strDescription { get; set; }
        public int? intDocumentType { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public bool ysnStandard { get; set; }
        public string strDocumentType { get; set; }
        public string strCertificationName { get; set; }
        public string strCertificationCode { get; set; }
        public string strCertificationIdName { get; set; }
    }

}
