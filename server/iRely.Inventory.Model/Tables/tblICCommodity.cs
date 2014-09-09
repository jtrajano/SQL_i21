using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCommodity : BaseEntity
    {
        public int intCommodityId { get; set; }
        public int strCommodityCode { get; set; }
        public int strDescription { get; set; }
        public int intDecimalDPR { get; set; }
        public double dblConsolidateFactor { get; set; }
        public bool ysnFXExposure { get; set; }
        public double dblPriceCheckMin { get; set; }
        public double dblPriceCheckMax { get; set; }
        public int strCheckoffTaxDesc { get; set; }
        public int strCheckoffAllState { get; set; }
        public int strInsuranceTaxDesc { get; set; }
        public int strInsuranceAllState { get; set; }
        public DateTime dtmCropEndDateCurrent { get; set; }
        public DateTime dtmCropEndDateNew { get; set; }
        public int strEDICode { get; set; }
        public int strScheduleStore { get; set; }
        public int strScheduleDiscount { get; set; }
        public int strTextPurchase { get; set; }
        public int strTextSales { get; set; }
        public int strTextFees { get; set; }
        public int strAGItemNumber { get; set; }
        public int strScaleAutoDist { get; set; }
        public bool ysnRequireLoadNumber { get; set; }
        public bool ysnAllowVariety { get; set; }
        public bool ysnAllowLoadContracts { get; set; }
        public double dblMaxUnder { get; set; }
        public double dblMaxOver { get; set; }
        public int intPatronageCategoryId { get; set; }
        public int intPatronageCategoryDirectId { get; set; }
    }
}
