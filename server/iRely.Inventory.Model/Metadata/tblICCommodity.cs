using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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

            this.tblICCommodityClassVariants = new List<tblICCommodityClassVariant>();
            this.tblICCommodityGrades = new List<tblICCommodityGrade>();
            this.tblICCommodityOrigins = new List<tblICCommodityOrigin>();
            this.tblICCommodityProductLines = new List<tblICCommodityProductLine>();
            this.tblICCommodityProductTypes = new List<tblICCommodityProductType>();
            this.tblICCommodityRegions = new List<tblICCommodityRegion>();
            this.tblICCommoditySeasons = new List<tblICCommoditySeason>();
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

        public ICollection<tblICItem> tblICItems { get; set; }
        public ICollection<tblICCommodityGroup> tblICCommodityGroups { get; set; }
        public ICollection<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public ICollection<tblICCommodityAccount> tblICCommodityAccounts { get; set; }

        public ICollection<tblICCommodityClassVariant> tblICCommodityClassVariants { get; set; }
        public ICollection<tblICCommodityGrade> tblICCommodityGrades { get; set; }
        public ICollection<tblICCommodityOrigin> tblICCommodityOrigins { get; set; }
        public ICollection<tblICCommodityProductLine> tblICCommodityProductLines { get; set; }
        public ICollection<tblICCommodityProductType> tblICCommodityProductTypes { get; set; }
        public ICollection<tblICCommodityRegion> tblICCommodityRegions { get; set; }
        public ICollection<tblICCommoditySeason> tblICCommoditySeasons { get; set; }

        public ICollection<tblICCertificationCommodity> tblICCertificationCommodities { get; set; }

    }

    public class CommodityVM
    {
        public int intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public string strDescription { get; set; }
    }

    public class tblICCommodityAccount : BaseEntity
    {
        public int intCommodityAccountId { get; set; }
        public int intCommodityId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public int? intAccountId { get; set; }
        public int? intSort { get; set; }

        private string _accountid;
        [NotMapped]
        public string strAccountId
        {
            get
            {
                if (string.IsNullOrEmpty(_accountid))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountId;
                    else
                        return null;
                else
                    return _accountid;
            }
            set
            {
                _accountid = value;
            }
        }
        private string _accountdesc;
        [NotMapped]
        public string strAccountDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_accountdesc))
                    if (tblGLAccount != null)
                        return tblGLAccount.strDescription;
                    else
                        return null;
                else
                    return _accountdesc;
            }
            set
            {
                _accountdesc = value;
            }
        }
        private string _accountGroup;
        [NotMapped]
        public string strAccountGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_accountGroup))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountGroup;
                    else
                        return null;
                else
                    return _accountGroup;
            }
            set
            {
                _accountGroup = value;
            }
        }
        private string _accountCategory;
        [NotMapped]
        public string strAccountCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_accountCategory))
                    if (tblGLAccountCategory != null)
                        return tblGLAccountCategory.strAccountCategory;
                    else
                        return null;
                else
                    return _accountCategory;
            }
            set
            {
                _accountCategory = value;
            }
        }

        public tblICCommodity tblICCommodity { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
        public tblGLAccountCategory tblGLAccountCategory { get; set; }
    }

    public class tblICCommodityAttribute : BaseEntity
    {
        public int intCommodityAttributeId { get; set; }
        //public int intCommodityId { get; set; }
        //public string strType { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }
    }

    public class tblICCommodityOrigin : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityProductType : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityRegion : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityClassVariant : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommoditySeason : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityGrade : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityProductLine : tblICCommodityAttribute
    {
        public int intCommodityId { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityGroup : BaseEntity
    {
        public int intCommodityGroupId { get; set; }
        public int intCommodityId { get; set; }
        public int intParentGroupId { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }

        public tblICCommodity tblICCommodity { get; set; }
    }

    public class tblICCommodityUnitMeasure : BaseEntity
    {
        public int intCommodityUnitMeasureId { get; set; }
        public int intCommodityId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnDefault { get; set; }
        public int? intSort { get; set; }

        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _unitmeasure;
            }
            set
            {
                _unitmeasure = value;
            }
        }

        public tblICCommodity tblICCommodity { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }

}
