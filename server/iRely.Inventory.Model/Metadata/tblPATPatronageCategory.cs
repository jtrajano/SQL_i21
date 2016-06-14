using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using System.ComponentModel.DataAnnotations;

namespace iRely.Inventory.Model
{
    public class tblPATPatronageCategory : BaseEntity
    {
        [Key]
        public int intPatronageCategoryId { get; set; }
        [Required]
        public string strCategoryCode { get; set; }
        public string strDescription { get; set; }
        public string strPurchaseSale { get; set; }
        public string strUnitAmount { get; set; }
    }
}
