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
        public bool? ysnExchangeTraded { get; set; }
        public int? intFutureMarketId { get; set; }
        public int? intDecimalDPR { get; set; }
        public decimal? dblConsolidateFactor { get; set; }
        public bool? ysnFXExposure { get; set; }
        public decimal? dblPriceCheckMin { get; set; }
        public decimal? dblPriceCheckMax { get; set; }
        public string strCheckoffTaxDesc { get; set; }
        public string strCheckoffAllState { get; set; }
        public string strInsuranceTaxDesc { get; set; }
        public string strInsuranceAllState { get; set; }
        public DateTime? dtmCropEndDateCurrent { get; set; }
        public DateTime? dtmCropEndDateNew { get; set; }
        public string strEDICode { get; set; }
        public int? intScheduleStoreId { get; set; }
        public int? intScheduleDiscountId { get; set; }
        public int? intScaleAutoDistId { get; set; }
        public bool? ysnAllowLoadContracts { get; set; }
        public decimal? dblMaxUnder { get; set; }
        public decimal? dblMaxOver { get; set; }

        private string _futureMarketName;
        [NotMapped]
        public string strFutMarketName
        {
            get
            {
                if (string.IsNullOrEmpty(_futureMarketName))
                    if (vyuICCommodityLookUp != null)
                        return vyuICCommodityLookUp.strFutMarketName;
                    else
                        return null;
                else
                    return _futureMarketName;
            }
            set
            {
                _futureMarketName = value;
            }
        }

        private string _scheduleId;
        [NotMapped]
        public string strScheduleId
        {
            get
            {
                if (string.IsNullOrEmpty(_scheduleId))
                    if (vyuICCommodityLookUp != null)
                        return vyuICCommodityLookUp.strScheduleId;
                    else
                        return null;
                else
                    return _scheduleId;
            }
            set
            {
                _scheduleId = value;
            }
        }

        private string _discountId;
        [NotMapped]
        public string strDiscountId
        {
            get
            {
                if (string.IsNullOrEmpty(_discountId))
                    if (vyuICCommodityLookUp != null)
                        return vyuICCommodityLookUp.strDiscountId;
                    else
                        return null;
                else
                    return _discountId;
            }
            set
            {
                _discountId = value;
            }
        }

        private string _storageType;
        [NotMapped]
        public string strStorageTypeCode
        {
            get
            {
                if (string.IsNullOrEmpty(_storageType))
                    if (vyuICCommodityLookUp != null)
                        return vyuICCommodityLookUp.strStorageTypeCode;
                    else
                        return null;
                else
                    return _storageType;
            }
            set
            {
                _storageType = value;
            }
        }
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
        public ICollection<tblICDocument> tblICDocuments { get; set; }
        public vyuICCommodityLookUp vyuICCommodityLookUp { get; set; }

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
        public int? intCountryID { get; set; }
        public int? intDefaultPackingUOMId { get; set; }
        private string _strDefaultPackingUOM;
        [NotMapped]
        public string strDefaultPackingUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_strDefaultPackingUOM))
                {
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
                    return null;
                }
                return _strDefaultPackingUOM;
            }
            set
            {
                _strDefaultPackingUOM = value;
            }
        }
        public int? intPurchasingGroupId { get; set; }
        private string _strPurchasingGroup;
        [NotMapped]
        public string strPurchasingGroup
        {
            get
            {
                if(string.IsNullOrEmpty(_strPurchasingGroup))
                {
                    if (tblSMPurchasingGroup != null)
                        return tblSMPurchasingGroup.strName;
                    return null;
                }
                return _strPurchasingGroup;
            }
            set
            {
                _strPurchasingGroup = value;
            }
        }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblSMPurchasingGroup tblSMPurchasingGroup { get; set; }
    }

    public class tblSMPurchasingGroup : BaseEntity
    {
        public int intPurchasingGroupId { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }

        public ICollection<tblICCommodityOrigin> tblICCommodityOrigins { get; set; }
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

    public class tblICCommodityProductLine : BaseEntity
    {
        public int intCommodityProductLineId { get; set; }
        public int intCommodityId { get; set; }
        public string strDescription { get; set; }
        public bool? ysnDeltaHedge { get; set; }
        public decimal? dblDeltaPercent { get; set; }
        public int? intSort { get; set; }

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

    public class CommodityUOMVM
    {
        public int intCommodityUnitMeasureId { get; set; }
        public int intCommodityId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnDefault { get; set; }
        public int? intSort { get; set; }
        public string strUnitMeasure { get; set; }
    }

    public class vyuICCommodityLookUp
    {
        public int intCommodityId { get; set; }
        public string strFutMarketName { get; set; }
        public string strScheduleId { get; set; }
        public string strDiscountId { get; set; }
        public string strStorageTypeCode { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
    }
}
