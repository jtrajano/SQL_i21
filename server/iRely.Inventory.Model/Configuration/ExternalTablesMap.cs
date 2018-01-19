using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocationMap: EntityTypeConfiguration<tblSMCompanyLocation>
    {
        public tblSMCompanyLocationMap()
        {
            // Primary Key
            HasKey(t => t.intCompanyLocationId);

            // Table & Column Mappings
            ToTable("tblSMCompanyLocation");
            Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            Property(t => t.intProfitCenter).HasColumnName("intProfitCenter");
            Property(t => t.strAddress).HasColumnName("strAddress");
            Property(t => t.strCity).HasColumnName("strCity");
            Property(t => t.strCountry).HasColumnName("strCountry");
            Property(t => t.strFax).HasColumnName("strFax");
            Property(t => t.strLocationName).HasColumnName("strLocationName");
            Property(t => t.strLocationType).HasColumnName("strLocationType");
            Property(t => t.strPhone).HasColumnName("strPhone");
            Property(t => t.strStateProvince).HasColumnName("strStateProvince");
            Property(t => t.strZipPostalCode).HasColumnName("strZipPostalCode");
            
        }
    }

    public class tblAPVendorPricingMap : EntityTypeConfiguration<tblAPVendorPricing>
    {
        public tblAPVendorPricingMap()
        {
            ToTable("tblAPVendorPricing");
            HasKey(t => t.intVendorPricingId);
            Property(t => t.intVendorPricingId).HasColumnName("intVendorPricingId");
            Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            Property(t => t.intItemId).HasColumnName("intItemId");
            Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            Property(t => t.intEntityLocationId).HasColumnName("intEntityLocationId");
            Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            Property(t => t.dblUnit).HasColumnName("dblUnit").HasPrecision(18, 6);
        }
    }

    public class tblGLAccountMap : EntityTypeConfiguration<tblGLAccount>
    {
        public tblGLAccountMap()
        {
            // Primary Key
            HasKey(t => t.intAccountId);

            // Table & Column Mappings
            ToTable("vyuGLAccountView");
            Property(t => t.intAccountId).HasColumnName("intAccountId");
            Property(t => t.strAccountId).HasColumnName("strAccountId");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strAccountGroup).HasColumnName("strAccountGroup");
        }
    }

    public class tblGLAccountGroupMap : EntityTypeConfiguration<tblGLAccountGroup>
    {
        public tblGLAccountGroupMap()
        {
            // Primary Key
            HasKey(t => t.intAccountGroupId);

            // Table & Column Mappings
            ToTable("tblGLAccountGroup");
            Property(t => t.intAccountGroupId).HasColumnName("intAccountGroupId");
            Property(t => t.strAccountGroup).HasColumnName("strAccountGroup");
            Property(t => t.strAccountGroupNamespace).HasColumnName("strAccountGroupNamespace");
            Property(t => t.intAccountBegin).HasColumnName("intAccountBegin");
            Property(t => t.intAccountEnd).HasColumnName("intAccountEnd");
            Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            Property(t => t.intAccountRangeId).HasColumnName("intAccountRangeId");
            Property(t => t.intEntityIdLastModified).HasColumnName("intEntityIdLastModified");
            Property(t => t.intGroup).HasColumnName("intGroup");
            Property(t => t.intParentGroupId).HasColumnName("intParentGroupId");
            Property(t => t.strAccountType).HasColumnName("strAccountType");
        }
    }

    public class tblGLAccountCategoryMap : EntityTypeConfiguration<tblGLAccountCategory>
    {
        public tblGLAccountCategoryMap()
        {
            // Primary Key
            HasKey(t => t.intAccountCategoryId);

            // Table & Column Mappings
            ToTable("tblGLAccountCategory");
            Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            Property(t => t.strAccountCategory).HasColumnName("strAccountCategory");
            Property(t => t.strAccountGroupFilter).HasColumnName("strAccountGroupFilter");
            Property(t => t.ysnRestricted).HasColumnName("ysnRestricted");
            Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
        }
    }

    public class vyuSMGetCompanyLocationSearchListMap : EntityTypeConfiguration<vyuSMGetCompanyLocationSearchList>
    {
        public vyuSMGetCompanyLocationSearchListMap()
        {
            HasKey(t => t.intCompanyLocationId);

            ToTable("vyuSMGetCompanyLocationSearchList");
            Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            Property(t => t.strLocationName).HasColumnName("strLocationName");
            Property(t => t.strLocationNumber).HasColumnName("strLocationNumber");
            Property(t => t.strLocationType).HasColumnName("strLocationType");
        }
    }

    public class vyuAPVendorMap : EntityTypeConfiguration<vyuAPVendor>
    {
        public vyuAPVendorMap()
        {
            // Primary Key
            HasKey(t => t.intEntityId);

            // Table & Column Mappings
            ToTable("vyuAPVendor");
            Property(t => t.intEntityId).HasColumnName("intEntityId");
            Property(t => t.strName).HasColumnName("strName");
            Property(t => t.strVendorAccountNum).HasColumnName("strVendorAccountNum");
            Property(t => t.strVendorId).HasColumnName("strVendorId");
        }
    }

    public class tblARCustomerMap : EntityTypeConfiguration<tblARCustomer>
    {
        public tblARCustomerMap()
        {
            // Primary Key
            HasKey(t => t.intEntityId);

            // Table & Column Mappings
            ToTable("vyuARCustomerSearch");
            Property(t => t.intEntityId).HasColumnName("intEntityId");
            Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            Property(t => t.strCustomerName).HasColumnName("strName");
        }
    }

    public class tbltblSMUserSecurityMap : EntityTypeConfiguration<tblSMUserSecurity>
    {
        public tbltblSMUserSecurityMap()
        {
            // Primary Key
            HasKey(t => t.intEntityId);

            // Table & Column Mappings
            ToTable("tblSMUserSecurity");
            Property(t => t.intEntityId).HasColumnName("intEntityId");
            Property(t => t.strUserName).HasColumnName("strUserName");
            Property(t => t.strFullName).HasColumnName("strFullName");
        }
    }

    public class tblEMEntityMap : EntityTypeConfiguration<tblEMEntity>
    {
        public tblEMEntityMap()
        {
            HasKey(e => e.intEntityId);
            ToTable("tblEMEntity");
        }
    }

    public class tblSMCountryMap : EntityTypeConfiguration<tblSMCountry>
    {
        public tblSMCountryMap()
        {
            // Primary Key
            HasKey(t => t.intCountryID);

            // Table & Column Mappings
            ToTable("tblSMCountry");
            Property(t => t.intCountryID).HasColumnName("intCountryID");
            Property(t => t.strCountry).HasColumnName("strCountry");   
        }
    }

    public class tblSMCurrencyMap : EntityTypeConfiguration<tblSMCurrency>
    {
        public tblSMCurrencyMap()
        {
            // Primary Key
            HasKey(t => t.intCurrencyID);

            // Table & Column Mappings
            ToTable("tblSMCurrency");
            Property(t => t.intCurrencyID).HasColumnName("intCurrencyID");
            Property(t => t.strCurrency).HasColumnName("strCurrency");
            Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }

    public class tblSTStoreMap : EntityTypeConfiguration<tblSTStore>
    {
        public tblSTStoreMap()
        {
            // Primary Key
            HasKey(t => t.intStoreId);

            // Table & Column Mappings
            ToTable("tblSTStore");
            Property(t => t.intStoreId).HasColumnName("intStoreId");
            Property(t => t.intStoreNo).HasColumnName("intStoreNo");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strDestrict).HasColumnName("strDestrict");
            Property(t => t.strRegion).HasColumnName("strRegion");
            Property(t => t.strStoreName).HasColumnName("strStoreName");
        }
    }

    public class tblSTSubcategoryMap : EntityTypeConfiguration<tblSTSubcategory>
    {
        public tblSTSubcategoryMap()
        {
            // Primary Key
            HasKey(t => t.intSubcategoryId);

            // Table & Column Mappings
            ToTable("tblSTSubcategory");
            Property(t => t.intSubcategoryId).HasColumnName("intSubcategoryId");
            Property(t => t.strSubcategoryType).HasColumnName("strSubcategoryType");
            Property(t => t.strSubcategoryId).HasColumnName("strSubcategoryId");
            Property(t => t.strSubcategoryDesc).HasColumnName("strSubcategoryDesc");
            Property(t => t.strSubCategoryComment).HasColumnName("strSubCategoryComment");
        }
    }

    public class tblSTSubcategoryRegProdMap : EntityTypeConfiguration<tblSTSubcategoryRegProd>
    {
        public tblSTSubcategoryRegProdMap()
        {
            // Primary Key
            HasKey(t => t.intRegProdId);

            // Table & Column Mappings
            ToTable("tblSTSubcategoryRegProd");
            Property(t => t.intRegProdId).HasColumnName("intRegProdId");
            Property(t => t.intStoreId).HasColumnName("intStoreId");
            Property(t => t.strRegProdCode).HasColumnName("strRegProdCode");
            Property(t => t.strRegProdComment).HasColumnName("strRegProdComment ");
            Property(t => t.strRegProdDesc).HasColumnName("strRegProdDesc");
        }
    }

    public class tblSTPaidOutMap : EntityTypeConfiguration<tblSTPaidOut>
    {
        public tblSTPaidOutMap()
        {
            // Primary Key
            HasKey(t => t.intPaidOutId);

            // Table & Column Mappings
            ToTable("tblSTPaidOut");
            Property(t => t.intAccountId).HasColumnName("intAccountId");
            Property(t => t.intPaidOutId).HasColumnName("intPaidOutId");
            Property(t => t.intPaymentMethodId).HasColumnName("intPaymentMethodId");
            Property(t => t.intStoreId).HasColumnName("intStoreId");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strPaidOutId).HasColumnName("strPaidOutId");
        }
    }

    public class tblGRStorageTypeMap : EntityTypeConfiguration<tblGRStorageType>
    {
        public tblGRStorageTypeMap()
        {
            // Primary Key
            HasKey(t => t.intStorageTypeId);

            // Table & Column Mappings
            ToTable("tblGRStorageType");
            Property(t => t.intStorageTypeId).HasColumnName("intStorageTypeId");
            Property(t => t.strStorageType).HasColumnName("strStorageType");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblSTPromotionSalesListMap : EntityTypeConfiguration<tblSTPromotionSalesList>
    {
        public tblSTPromotionSalesListMap()
        {
            // Primary Key
            HasKey(t => t.intPromoSalesListId);

            // Table & Column Mappings
            ToTable("tblSTPromotionSalesList");
            Property(t => t.dblPromoPrice).HasColumnName("dblPromoPrice");
            Property(t => t.intPromoSalesListId).HasColumnName("intPromoSalesListId");
            Property(t => t.intPromoUnits).HasColumnName("intPromoUnits");
            Property(t => t.intPromoCode).HasColumnName("intPromoSalesId");
            Property(t => t.strDescription).HasColumnName("strPromoSalesDescription");
            Property(t => t.strPromoType).HasColumnName("strPromoType");
        }
    }

    public class tblSMStartingNumberMap : EntityTypeConfiguration<tblSMStartingNumber>
    {
        public tblSMStartingNumberMap()
        {
            // Primary Key
            HasKey(t => t.intStartingNumberId);

            // Table & Column Mappings
            ToTable("tblSMStartingNumber");
            Property(t => t.intNumber).HasColumnName("intNumber");
            Property(t => t.intStartingNumberId).HasColumnName("intStartingNumberId");
            Property(t => t.strModule).HasColumnName("strModule");
            Property(t => t.strPrefix).HasColumnName("strPrefix");
            Property(t => t.strTransactionType).HasColumnName("strTransactionType");
            Property(t => t.ysnEnable).HasColumnName("ysnEnable");
        }
    }
    
 /*   public class tblMFQAPropertyMap : EntityTypeConfiguration<tblMFQAProperty>
    {
        public tblMFQAPropertyMap()
        {
            // Primary Key
            HasKey(t => t.intQAPropertyId);

            // Table & Column Mappings
            ToTable("tblMFQAProperty");
            Property(t => t.intDecimalPlaces).HasColumnName("intDecimalPlaces");
            Property(t => t.intQAPropertyId).HasColumnName("intQAPropertyId");
            Property(t => t.strAnalysisType).HasColumnName("strAnalysisType");
            Property(t => t.strDataType).HasColumnName("strDataType");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strListName).HasColumnName("strListName");
            Property(t => t.strMandatory).HasColumnName("strMandatory");
            Property(t => t.strPropertyName).HasColumnName("strPropertyName");
            Property(t => t.ysnActive).HasColumnName("ysnActive");
        }
    }*/

    public class tblSMCompanyLocationSubLocationMap : EntityTypeConfiguration<tblSMCompanyLocationSubLocation>
    {
        public tblSMCompanyLocationSubLocationMap()
        {
            // Primary Key
            HasKey(t => t.intCompanyLocationSubLocationId);

            // Table & Column Mappings
            ToTable("tblSMCompanyLocationSubLocation");
            Property(t => t.intCompanyLocationSubLocationId).HasColumnName("intCompanyLocationSubLocationId");
            Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            Property(t => t.strSubLocationDescription).HasColumnName("strSubLocationDescription");
            Property(t => t.strClassification).HasColumnName("strClassification");
            Property(t => t.intNewLotBin).HasColumnName("intNewLotBin");
            Property(t => t.intAuditBin).HasColumnName("intAuditBin");
            Property(t => t.strAddress).HasColumnName("strAddress");
        }
    }

    public class tblSMTaxCodeMap : EntityTypeConfiguration<tblSMTaxCode>
    {
        public tblSMTaxCodeMap()
        {
            // Primary Key
            HasKey(t => t.intTaxCodeId);

            // Table & Column Mappings
            ToTable("tblSMTaxCode");
            Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            Property(t => t.numRate).HasColumnName("numRate").HasPrecision(18, 6);
            Property(t => t.strTaxAgency).HasColumnName("strTaxAgency");
            Property(t => t.strAddress).HasColumnName("strAddress");
            Property(t => t.strZipCode).HasColumnName("strZipCode");
            Property(t => t.strState).HasColumnName("strState");
            Property(t => t.strCity).HasColumnName("strCity");
            Property(t => t.strCountry).HasColumnName("strCountry");
            Property(t => t.strCounty).HasColumnName("strCounty");
            Property(t => t.intSalesTaxAccountId).HasColumnName("intSalesTaxAccountId");
            Property(t => t.intPurchaseTaxAccountId).HasColumnName("intPurchaseTaxAccountId");
            Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
        }
    }

    public class tblICMaterialNMFCMap : EntityTypeConfiguration<tblICMaterialNMFC>
    {
        public tblICMaterialNMFCMap()
        {
            // Primary Key
            HasKey(t => t.intMaterialNMFCId);

            // Table & Column Mappings
            ToTable("tblICMaterialNMFC");
            Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            Property(t => t.intMaterialNMFCId).HasColumnName("intMaterialNMFCId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            Property(t => t.ysnLocked).HasColumnName("ysnLocked");
        }
    }

    public class tblICReasonCodeMap : EntityTypeConfiguration<tblICReasonCode>
    {
        public tblICReasonCodeMap()
        {
            // Primary Key
            HasKey(t => t.intReasonCodeId);

            // Table & Column Mappings
            ToTable("tblICReasonCode");
            Property(t => t.dtmLastUpdatedOn).HasColumnName("dtmLastUpdatedOn");
            Property(t => t.intReasonCodeId).HasColumnName("intReasonCodeId");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strLastUpdatedBy).HasColumnName("strLastUpdatedBy");
            Property(t => t.strLotTransactionType).HasColumnName("strLotTransactionType");
            Property(t => t.strReasonCode).HasColumnName("strReasonCode");
            Property(t => t.strType).HasColumnName("strType");
            Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            Property(t => t.ysnExplanationRequired).HasColumnName("ysnExplanationRequired");
            Property(t => t.ysnReduceAvailableTime).HasColumnName("ysnReduceAvailableTime");
        }
    }

    public class tblICReasonCodeWorkCenterMap : EntityTypeConfiguration<tblICReasonCodeWorkCenter>
    {
        public tblICReasonCodeWorkCenterMap()
        {
            // Primary Key
            HasKey(t => t.intReasonCodeWorkCenterId);

            // Table & Column Mappings
            ToTable("tblICReasonCodeWorkCenter");
            Property(t => t.intReasonCodeId).HasColumnName("intReasonCodeId");
            Property(t => t.intReasonCodeWorkCenterId).HasColumnName("intReasonCodeWorkCenterId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.strWorkCenterId).HasColumnName("strWorkCenterId");
        }
    }

    public class tblICContainerMap : EntityTypeConfiguration<tblICContainer>
    {
        public tblICContainerMap()
        {
            // Primary Key
            HasKey(t => t.intContainerId);

            // Table & Column Mappings
            ToTable("tblICContainer");
            Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            Property(t => t.intContainerId).HasColumnName("intContainerId");
            Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            Property(t => t.strContainerId).HasColumnName("strContainerId");
            Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
        }
    }

    public class tblICContainerTypeMap : EntityTypeConfiguration<tblICContainerType>
    {
        public tblICContainerTypeMap()
        {
            // Primary Key
            HasKey(t => t.intContainerTypeId);

            // Table & Column Mappings
            ToTable("tblICContainerType");
            Property(t => t.dblDepth).HasColumnName("dblDepth").HasPrecision(18, 6);
            Property(t => t.dblHeight).HasColumnName("dblHeight").HasPrecision(18, 6);
            Property(t => t.dblMaxWeight).HasColumnName("dblMaxWeight").HasPrecision(18, 6);
            Property(t => t.dblPalletWeight).HasColumnName("dblPalletWeight").HasPrecision(18, 6);
            Property(t => t.dblWidth).HasColumnName("dblWidth").HasPrecision(18, 6);
            Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            Property(t => t.intDimensionUnitMeasureId).HasColumnName("intDimensionUnitMeasureId");
            Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.intTareUnitMeasureId).HasColumnName("intTareUnitMeasureId");
            Property(t => t.intWeightUnitMeasureId).HasColumnName("intWeightUnitMeasureId");
            Property(t => t.strContainerDescription).HasColumnName("strContainerDescription");
            Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            Property(t => t.ysnAllowMultipleItems).HasColumnName("ysnAllowMultipleItems");
            Property(t => t.ysnAllowMultipleLots).HasColumnName("ysnAllowMultipleLots");
            Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            Property(t => t.ysnLocked).HasColumnName("ysnLocked");
            Property(t => t.ysnMergeOnMove).HasColumnName("ysnMergeOnMove");
            Property(t => t.ysnReusable).HasColumnName("ysnReusable");
        }
    }

    public class tblICMeasurementMap : EntityTypeConfiguration<tblICMeasurement>
    {
        public tblICMeasurementMap()
        {
            // Primary Key
            HasKey(t => t.intMeasurementId);

            // Table & Column Mappings
            ToTable("tblICMeasurement");
            Property(t => t.intMeasurementId).HasColumnName("intMeasurementId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strMeasurementName).HasColumnName("strMeasurementName");
            Property(t => t.strMeasurementType).HasColumnName("strMeasurementType");
        }
    }

    public class tblICReadingPointMap : EntityTypeConfiguration<tblICReadingPoint>
    {
        public tblICReadingPointMap()
        {
            // Primary Key
            HasKey(t => t.intReadingPointId);

            // Table & Column Mappings
            ToTable("tblICReadingPoint");
            Property(t => t.intReadingPointId).HasColumnName("intReadingPointId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.strReadingPoint).HasColumnName("strReadingPoint");
        }
    }

    public class tblICRestrictionMap : EntityTypeConfiguration<tblICRestriction>
    {
        public tblICRestrictionMap()
        {
            // Primary Key
            HasKey(t => t.intRestrictionId);

            // Table & Column Mappings
            ToTable("tblICRestriction");
            Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            Property(t => t.intRestrictionId).HasColumnName("intRestrictionId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            Property(t => t.ysnLocked).HasColumnName("ysnLocked");
        }
    }

    public class tblICSkuMap : EntityTypeConfiguration<tblICSku>
    {
        public tblICSkuMap()
        {
            // Primary Key
            HasKey(t => t.intSKUId);

            // Table & Column Mappings
            ToTable("tblICSku");
            Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            Property(t => t.dblWeightPerUnit).HasColumnName("dblWeightPerUnit").HasPrecision(18, 6);
            Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            Property(t => t.dtmProductionDate).HasColumnName("dtmProductionDate");
            Property(t => t.dtmReceiveDate).HasColumnName("dtmReceiveDate");
            Property(t => t.intContainerId).HasColumnName("intContainerId");
            Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            Property(t => t.intItemId).HasColumnName("intItemId");
            Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            Property(t => t.intLotId).HasColumnName("intLotId");
            Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            Property(t => t.intParentSKUId).HasColumnName("intParentSKUId");
            Property(t => t.intReasonId).HasColumnName("intReasonId");
            Property(t => t.intSKUId).HasColumnName("intSKUId");
            Property(t => t.intSKUStatusId).HasColumnName("intSKUStatusId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            Property(t => t.intWeightPerUnitMeasureId).HasColumnName("intWeightPerUnitMeasureId");
            Property(t => t.strBatch).HasColumnName("strBatch");
            Property(t => t.strComment).HasColumnName("strComment");
            Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            Property(t => t.strLotCode).HasColumnName("strLotCode");
            Property(t => t.strSerialNo).HasColumnName("strSerialNo");
            Property(t => t.strSKU).HasColumnName("strSKU");
            Property(t => t.ysnSanitized).HasColumnName("ysnSanitized");
        }
    }

    public class tblICEquipmentLengthMap : EntityTypeConfiguration<tblICEquipmentLength>
    {
        public tblICEquipmentLengthMap()
        {
            // Primary Key
            HasKey(t => t.intEquipmentLengthId);

            // Table & Column Mappings
            ToTable("tblICEquipmentLength");
            Property(t => t.intEquipmentLengthId).HasColumnName("intEquipmentLengthId");
            Property(t => t.intSort).HasColumnName("intSort");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.strEquipmentLength).HasColumnName("strEquipmentLength");
        }
    }

    public class tblSMLicenseTypeMap : EntityTypeConfiguration<tblSMLicenseType>
    {
        public tblSMLicenseTypeMap()
        {
            //Primary Key
            HasKey(t => t.intLicenseTypeId);

            //Table & Column Mappings
            ToTable("tblSMLicenseType");
            Property(t => t.intLicenseTypeId).HasColumnName("intLicenseTypeId");
            Property(t => t.strCode).HasColumnName("strCode");
            Property(t => t.strDescription).HasColumnName("strDescription");
            Property(t => t.ysnRequiredForApplication).HasColumnName("ysnRequiredForApplication");
            Property(t => t.ysnRequiredForPurchase).HasColumnName("ysnRequiredForPurchase");

            
        }
    }

}
