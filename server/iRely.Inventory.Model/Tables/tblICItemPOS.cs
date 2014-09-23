using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemPOS : BaseEntity
    {
        public int intItemId { get; set; }
        public string strUPCNo { get; set; }
        public int intCaseUOM { get; set; }
        public string strNACSCategory { get; set; }
        public string strWICCode { get; set; }
        public int intAGCategory { get; set; }
        public bool ysnReceiptCommentRequired { get; set; }
        public string strCountCode { get; set; }
        public bool ysnLandedCost { get; set; }
        public string strLeadTime { get; set; }
        public bool ysnTaxable { get; set; }
        public string strKeywords { get; set; }
        public double dblCaseQty { get; set; }
        public DateTime dtmDateShip { get; set; }
        public double dblTaxExempt { get; set; }
        public bool ysnDropShip { get; set; }
        public bool ysnCommisionable { get; set; }
        public string strSpecialCommission { get; set; }

        public tblICItem tblICItem { get; set; }
        public ICollection<tblICItemPOSCategory> tblICItemPOSCategories { get; set; }
        public ICollection<tblICItemPOSSLA> tblICItemPOSSLAs { get; set; }
    }

    public class tblICItemPOSCategory : BaseEntity
    {
        public int intItemPOSCategoryId { get; set; }
        public int intItemId { get; set; }
        public int intCategoryId { get; set; }
        public int intSort { get; set; }

        public tblICItemPOS tblICItemPOS { get; set; }
    }

    public class tblICItemPOSSLA : BaseEntity
    {
        public int intItemPOSSLAId { get; set; }
        public int intItemId { get; set; }
        public string strSLAContract { get; set; }
        public double dblContractPrice { get; set; }
        public bool ysnServiceWarranty { get; set; }

        public tblICItemPOS tblICItemPOS { get; set; }
    }
}
