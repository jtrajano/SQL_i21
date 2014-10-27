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
        public tblICCommodity()
        {
            this.tblICCommodityGroups = new List<tblICCommodityGroup>();
            this.tblICCommodityUnitMeasures = new List<tblICCommodityUnitMeasure>();
            this.tblICCommodityAccounts = new List<tblICCommodityAccount>();
            this.tblICCommodityAttributes = new List<tblICCommodityAttribute>();
        }

        public int intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public string strDescription { get; set; }
        public bool ysnExchangeTraded { get; set; }
        public int intDecimalDPR { get; set; }
        public decimal? dblConsolidateFactor { get; set; }
        public bool ysnFXExposure { get; set; }
        public decimal? dblPriceCheckMin { get; set; }
        public decimal? dblPriceCheckMax { get; set; }
        public string strCheckoffTaxDesc { get; set; }
        public string strCheckoffAllState { get; set; }
        public string strInsuranceTaxDesc { get; set; }
        public string strInsuranceAllState { get; set; }
        public DateTime? dtmCropEndDateCurrent { get; set; }
        public DateTime? dtmCropEndDateNew { get; set; }
        public string strEDICode { get; set; }
        public string strScheduleStore { get; set; }
        public string strScheduleDiscount { get; set; }
        public string strTextPurchase { get; set; }
        public string strTextSales { get; set; }
        public string strTextFees { get; set; }
        public string strAGItemNumber { get; set; }
        public string strScaleAutoDist { get; set; }
        public bool ysnRequireLoadNumber { get; set; }
        public bool ysnAllowVariety { get; set; }
        public bool ysnAllowLoadContracts { get; set; }
        public decimal? dblMaxUnder { get; set; }
        public decimal? dblMaxOver { get; set; }
        public int? intPatronageCategoryId { get; set; }
        public int? intPatronageCategoryDirectId { get; set; }

        public tblICPatronageCategory PatronageCategory { get; set; }
        public tblICPatronageCategory PatronageCategoryDirect { get; set; }

        public ICollection<tblICCommodityGroup> tblICCommodityGroups { get; set; }
        public ICollection<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public ICollection<tblICCommodityAccount> tblICCommodityAccounts { get; set; }
        public ICollection<tblICCommodityAttribute> tblICCommodityAttributes { get; set; }

    }
}
