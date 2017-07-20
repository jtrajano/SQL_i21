using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemSubstitution : BaseEntity
    {
        public int intItemSubstitutionId { get; set; }
        public int intItemId { get; set; }
        public string strModification { get; set; }
        public string strComment { get; set; }
        public int? intSort { get; set; }
    }

    public class tblICItemSubstitutionDetail : BaseEntity
    {
        public int intItemSubstitutionDetailId { get; set; }
        public int intItemSubstitutionId { get; set; }
        public int intSubstituteItemId { get; set; }
        public DateTime? dtmValidFrom { get; set; }
        public DateTime? dtmValidTo { get; set; }
        public decimal? dblRatio { get; set; }
        public decimal? dblPercent { get; set; }
        public bool ysnYearValidationRequired { get; set; }
        public int? intSort { get; set; }
    }
}
