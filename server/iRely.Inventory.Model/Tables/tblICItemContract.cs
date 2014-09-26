using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemContract : BaseEntity
    {
        public int intItemContractId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strStoreName { get; set; }
        public string strContractItemName { get; set; }
        public int intCountryId { get; set; }
        public string strGrade { get; set; }
        public string strGradeType { get; set; }
        public string strGarden { get; set; }
        public double dblYieldPercent { get; set; }
        public double dblTolerancePercent { get; set; }
        public double dblFranchisePercent { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }

        public ICollection<tblICItemContractDocument> tblICItemContractDocuments { get; set; }
    }
}
