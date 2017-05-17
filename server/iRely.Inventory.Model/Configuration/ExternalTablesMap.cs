using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocationMap: EntityTypeConfiguration<tblSMCompanyLocation>
    {
        public tblSMCompanyLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intCompanyLocationId);

            // Table & Column Mappings
            this.ToTable("tblSMCompanyLocation");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.intProfitCenter).HasColumnName("intProfitCenter");
            this.Property(t => t.strAddress).HasColumnName("strAddress");
            this.Property(t => t.strCity).HasColumnName("strCity");
            this.Property(t => t.strCountry).HasColumnName("strCountry");
            this.Property(t => t.strFax).HasColumnName("strFax");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.strPhone).HasColumnName("strPhone");
            this.Property(t => t.strStateProvince).HasColumnName("strStateProvince");
            this.Property(t => t.strZipPostalCode).HasColumnName("strZipPostalCode");
            
        }
    }

    public class tblGLAccountMap : EntityTypeConfiguration<tblGLAccount>
    {
        public tblGLAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intAccountId);

            // Table & Column Mappings
            this.ToTable("vyuGLAccountView");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.strAccountId).HasColumnName("strAccountId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strAccountGroup).HasColumnName("strAccountGroup");
        }
    }

    public class tblGLAccountGroupMap : EntityTypeConfiguration<tblGLAccountGroup>
    {
        public tblGLAccountGroupMap()
        {
            // Primary Key
            this.HasKey(t => t.intAccountGroupId);

            // Table & Column Mappings
            this.ToTable("tblGLAccountGroup");
            this.Property(t => t.intAccountGroupId).HasColumnName("intAccountGroupId");
            this.Property(t => t.strAccountGroup).HasColumnName("strAccountGroup");
            this.Property(t => t.strAccountGroupNamespace).HasColumnName("strAccountGroupNamespace");
            this.Property(t => t.intAccountBegin).HasColumnName("intAccountBegin");
            this.Property(t => t.intAccountEnd).HasColumnName("intAccountEnd");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.intAccountRangeId).HasColumnName("intAccountRangeId");
            this.Property(t => t.intEntityIdLastModified).HasColumnName("intEntityIdLastModified");
            this.Property(t => t.intGroup).HasColumnName("intGroup");
            this.Property(t => t.intParentGroupId).HasColumnName("intParentGroupId");
            this.Property(t => t.strAccountType).HasColumnName("strAccountType");
        }
    }

    public class tblGLAccountCategoryMap : EntityTypeConfiguration<tblGLAccountCategory>
    {
        public tblGLAccountCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intAccountCategoryId);

            // Table & Column Mappings
            this.ToTable("tblGLAccountCategory");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.strAccountCategory).HasColumnName("strAccountCategory");
            this.Property(t => t.strAccountGroupFilter).HasColumnName("strAccountGroupFilter");
            this.Property(t => t.ysnRestricted).HasColumnName("ysnRestricted");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
        }
    }

    public class vyuSMGetCompanyLocationSearchListMap : EntityTypeConfiguration<vyuSMGetCompanyLocationSearchList>
    {
        public vyuSMGetCompanyLocationSearchListMap()
        {
            this.HasKey(t => t.intCompanyLocationId);

            this.ToTable("vyuSMGetCompanyLocationSearchList");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationNumber).HasColumnName("strLocationNumber");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
        }
    }

    public class vyuAPVendorMap : EntityTypeConfiguration<vyuAPVendor>
    {
        public vyuAPVendorMap()
        {
            // Primary Key
            this.HasKey(t => t.intEntityId);

            // Table & Column Mappings
            this.ToTable("vyuAPVendor");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strVendorAccountNum).HasColumnName("strVendorAccountNum");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
        }
    }

    public class tblARCustomerMap : EntityTypeConfiguration<tblARCustomer>
    {
        public tblARCustomerMap()
        {
            // Primary Key
            this.HasKey(t => t.intEntityId);

            // Table & Column Mappings
            this.ToTable("vyuARCustomerSearch");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strCustomerName).HasColumnName("strName");
        }
    }

    public class tblSMCountryMap : EntityTypeConfiguration<tblSMCountry>
    {
        public tblSMCountryMap()
        {
            // Primary Key
            this.HasKey(t => t.intCountryID);

            // Table & Column Mappings
            this.ToTable("tblSMCountry");
            this.Property(t => t.intCountryID).HasColumnName("intCountryID");
            this.Property(t => t.strCountry).HasColumnName("strCountry");   
        }
    }

    public class tblSMCurrencyMap : EntityTypeConfiguration<tblSMCurrency>
    {
        public tblSMCurrencyMap()
        {
            // Primary Key
            this.HasKey(t => t.intCurrencyID);

            // Table & Column Mappings
            this.ToTable("tblSMCurrency");
            this.Property(t => t.intCurrencyID).HasColumnName("intCurrencyID");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }

    public class tblSTStoreMap : EntityTypeConfiguration<tblSTStore>
    {
        public tblSTStoreMap()
        {
            // Primary Key
            this.HasKey(t => t.intStoreId);

            // Table & Column Mappings
            this.ToTable("tblSTStore");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.intStoreNo).HasColumnName("intStoreNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strDestrict).HasColumnName("strDestrict");
            this.Property(t => t.strRegion).HasColumnName("strRegion");
            this.Property(t => t.strStoreName).HasColumnName("strStoreName");
        }
    }

    public class tblSTSubcategoryMap : EntityTypeConfiguration<tblSTSubcategory>
    {
        public tblSTSubcategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intSubcategoryId);

            // Table & Column Mappings
            this.ToTable("tblSTSubcategory");
            this.Property(t => t.intSubcategoryId).HasColumnName("intSubcategoryId");
            this.Property(t => t.strSubcategoryType).HasColumnName("strSubcategoryType");
            this.Property(t => t.strSubcategoryId).HasColumnName("strSubcategoryId");
            this.Property(t => t.strSubcategoryDesc).HasColumnName("strSubcategoryDesc");
            this.Property(t => t.strSubCategoryComment).HasColumnName("strSubCategoryComment");
        }
    }

    public class tblSTSubcategoryRegProdMap : EntityTypeConfiguration<tblSTSubcategoryRegProd>
    {
        public tblSTSubcategoryRegProdMap()
        {
            // Primary Key
            this.HasKey(t => t.intRegProdId);

            // Table & Column Mappings
            this.ToTable("tblSTSubcategoryRegProd");
            this.Property(t => t.intRegProdId).HasColumnName("intRegProdId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.strRegProdCode).HasColumnName("strRegProdCode");
            this.Property(t => t.strRegProdComment).HasColumnName("strRegProdComment ");
            this.Property(t => t.strRegProdDesc).HasColumnName("strRegProdDesc");
        }
    }

    public class tblSTPaidOutMap : EntityTypeConfiguration<tblSTPaidOut>
    {
        public tblSTPaidOutMap()
        {
            // Primary Key
            this.HasKey(t => t.intPaidOutId);

            // Table & Column Mappings
            this.ToTable("tblSTPaidOut");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intPaidOutId).HasColumnName("intPaidOutId");
            this.Property(t => t.intPaymentMethodId).HasColumnName("intPaymentMethodId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPaidOutId).HasColumnName("strPaidOutId");
        }
    }

    public class tblGRStorageTypeMap : EntityTypeConfiguration<tblGRStorageType>
    {
        public tblGRStorageTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageTypeId);

            // Table & Column Mappings
            this.ToTable("tblGRStorageType");
            this.Property(t => t.intStorageTypeId).HasColumnName("intStorageTypeId");
            this.Property(t => t.strStorageType).HasColumnName("strStorageType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblSTPromotionSalesListMap : EntityTypeConfiguration<tblSTPromotionSalesList>
    {
        public tblSTPromotionSalesListMap()
        {
            // Primary Key
            this.HasKey(t => t.intPromoSalesListId);

            // Table & Column Mappings
            this.ToTable("tblSTPromotionSalesList");
            this.Property(t => t.dblPromoPrice).HasColumnName("dblPromoPrice");
            this.Property(t => t.intPromoSalesListId).HasColumnName("intPromoSalesListId");
            this.Property(t => t.intPromoUnits).HasColumnName("intPromoUnits");
            this.Property(t => t.intPromoCode).HasColumnName("intPromoSalesId");
            this.Property(t => t.strDescription).HasColumnName("strPromoSalesDescription");
            this.Property(t => t.strPromoType).HasColumnName("strPromoType");
        }
    }

    public class tblSMStartingNumberMap : EntityTypeConfiguration<tblSMStartingNumber>
    {
        public tblSMStartingNumberMap()
        {
            // Primary Key
            this.HasKey(t => t.intStartingNumberId);

            // Table & Column Mappings
            this.ToTable("tblSMStartingNumber");
            this.Property(t => t.intNumber).HasColumnName("intNumber");
            this.Property(t => t.intStartingNumberId).HasColumnName("intStartingNumberId");
            this.Property(t => t.strModule).HasColumnName("strModule");
            this.Property(t => t.strPrefix).HasColumnName("strPrefix");
            this.Property(t => t.strTransactionType).HasColumnName("strTransactionType");
            this.Property(t => t.ysnEnable).HasColumnName("ysnEnable");
        }
    }
    
 /*   public class tblMFQAPropertyMap : EntityTypeConfiguration<tblMFQAProperty>
    {
        public tblMFQAPropertyMap()
        {
            // Primary Key
            this.HasKey(t => t.intQAPropertyId);

            // Table & Column Mappings
            this.ToTable("tblMFQAProperty");
            this.Property(t => t.intDecimalPlaces).HasColumnName("intDecimalPlaces");
            this.Property(t => t.intQAPropertyId).HasColumnName("intQAPropertyId");
            this.Property(t => t.strAnalysisType).HasColumnName("strAnalysisType");
            this.Property(t => t.strDataType).HasColumnName("strDataType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strListName).HasColumnName("strListName");
            this.Property(t => t.strMandatory).HasColumnName("strMandatory");
            this.Property(t => t.strPropertyName).HasColumnName("strPropertyName");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
        }
    }*/

    public class tblSMCompanyLocationSubLocationMap : EntityTypeConfiguration<tblSMCompanyLocationSubLocation>
    {
        public tblSMCompanyLocationSubLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intCompanyLocationSubLocationId);

            // Table & Column Mappings
            this.ToTable("tblSMCompanyLocationSubLocation");
            this.Property(t => t.intCompanyLocationSubLocationId).HasColumnName("intCompanyLocationSubLocationId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strSubLocationDescription).HasColumnName("strSubLocationDescription");
            this.Property(t => t.strClassification).HasColumnName("strClassification");
            this.Property(t => t.intNewLotBin).HasColumnName("intNewLotBin");
            this.Property(t => t.intAuditBin).HasColumnName("intAuditBin");
            this.Property(t => t.strAddress).HasColumnName("strAddress");
        }
    }

    public class tblSMTaxCodeMap : EntityTypeConfiguration<tblSMTaxCode>
    {
        public tblSMTaxCodeMap()
        {
            // Primary Key
            this.HasKey(t => t.intTaxCodeId);

            // Table & Column Mappings
            this.ToTable("tblSMTaxCode");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.numRate).HasColumnName("numRate").HasPrecision(18, 6);
            this.Property(t => t.strTaxAgency).HasColumnName("strTaxAgency");
            this.Property(t => t.strAddress).HasColumnName("strAddress");
            this.Property(t => t.strZipCode).HasColumnName("strZipCode");
            this.Property(t => t.strState).HasColumnName("strState");
            this.Property(t => t.strCity).HasColumnName("strCity");
            this.Property(t => t.strCountry).HasColumnName("strCountry");
            this.Property(t => t.strCounty).HasColumnName("strCounty");
            this.Property(t => t.intSalesTaxAccountId).HasColumnName("intSalesTaxAccountId");
            this.Property(t => t.intPurchaseTaxAccountId).HasColumnName("intPurchaseTaxAccountId");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
        }
    }

    public class tblICMaterialNMFCMap : EntityTypeConfiguration<tblICMaterialNMFC>
    {
        public tblICMaterialNMFCMap()
        {
            // Primary Key
            this.HasKey(t => t.intMaterialNMFCId);

            // Table & Column Mappings
            this.ToTable("tblICMaterialNMFC");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intMaterialNMFCId).HasColumnName("intMaterialNMFCId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnLocked).HasColumnName("ysnLocked");
        }
    }

    public class tblICReasonCodeMap : EntityTypeConfiguration<tblICReasonCode>
    {
        public tblICReasonCodeMap()
        {
            // Primary Key
            this.HasKey(t => t.intReasonCodeId);

            // Table & Column Mappings
            this.ToTable("tblICReasonCode");
            this.Property(t => t.dtmLastUpdatedOn).HasColumnName("dtmLastUpdatedOn");
            this.Property(t => t.intReasonCodeId).HasColumnName("intReasonCodeId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strLastUpdatedBy).HasColumnName("strLastUpdatedBy");
            this.Property(t => t.strLotTransactionType).HasColumnName("strLotTransactionType");
            this.Property(t => t.strReasonCode).HasColumnName("strReasonCode");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnExplanationRequired).HasColumnName("ysnExplanationRequired");
            this.Property(t => t.ysnReduceAvailableTime).HasColumnName("ysnReduceAvailableTime");
        }
    }

    public class tblICReasonCodeWorkCenterMap : EntityTypeConfiguration<tblICReasonCodeWorkCenter>
    {
        public tblICReasonCodeWorkCenterMap()
        {
            // Primary Key
            this.HasKey(t => t.intReasonCodeWorkCenterId);

            // Table & Column Mappings
            this.ToTable("tblICReasonCodeWorkCenter");
            this.Property(t => t.intReasonCodeId).HasColumnName("intReasonCodeId");
            this.Property(t => t.intReasonCodeWorkCenterId).HasColumnName("intReasonCodeWorkCenterId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strWorkCenterId).HasColumnName("strWorkCenterId");
        }
    }

    public class tblICContainerMap : EntityTypeConfiguration<tblICContainer>
    {
        public tblICContainerMap()
        {
            // Primary Key
            this.HasKey(t => t.intContainerId);

            // Table & Column Mappings
            this.ToTable("tblICContainer");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strContainerId).HasColumnName("strContainerId");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
        }
    }

    public class tblICContainerTypeMap : EntityTypeConfiguration<tblICContainerType>
    {
        public tblICContainerTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intContainerTypeId);

            // Table & Column Mappings
            this.ToTable("tblICContainerType");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth").HasPrecision(18, 6);
            this.Property(t => t.dblHeight).HasColumnName("dblHeight").HasPrecision(18, 6);
            this.Property(t => t.dblMaxWeight).HasColumnName("dblMaxWeight").HasPrecision(18, 6);
            this.Property(t => t.dblPalletWeight).HasColumnName("dblPalletWeight").HasPrecision(18, 6);
            this.Property(t => t.dblWidth).HasColumnName("dblWidth").HasPrecision(18, 6);
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            this.Property(t => t.intDimensionUnitMeasureId).HasColumnName("intDimensionUnitMeasureId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intTareUnitMeasureId).HasColumnName("intTareUnitMeasureId");
            this.Property(t => t.intWeightUnitMeasureId).HasColumnName("intWeightUnitMeasureId");
            this.Property(t => t.strContainerDescription).HasColumnName("strContainerDescription");
            this.Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.ysnAllowMultipleItems).HasColumnName("ysnAllowMultipleItems");
            this.Property(t => t.ysnAllowMultipleLots).HasColumnName("ysnAllowMultipleLots");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnLocked).HasColumnName("ysnLocked");
            this.Property(t => t.ysnMergeOnMove).HasColumnName("ysnMergeOnMove");
            this.Property(t => t.ysnReusable).HasColumnName("ysnReusable");
        }
    }

    public class tblICMeasurementMap : EntityTypeConfiguration<tblICMeasurement>
    {
        public tblICMeasurementMap()
        {
            // Primary Key
            this.HasKey(t => t.intMeasurementId);

            // Table & Column Mappings
            this.ToTable("tblICMeasurement");
            this.Property(t => t.intMeasurementId).HasColumnName("intMeasurementId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strMeasurementName).HasColumnName("strMeasurementName");
            this.Property(t => t.strMeasurementType).HasColumnName("strMeasurementType");
        }
    }

    public class tblICReadingPointMap : EntityTypeConfiguration<tblICReadingPoint>
    {
        public tblICReadingPointMap()
        {
            // Primary Key
            this.HasKey(t => t.intReadingPointId);

            // Table & Column Mappings
            this.ToTable("tblICReadingPoint");
            this.Property(t => t.intReadingPointId).HasColumnName("intReadingPointId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strReadingPoint).HasColumnName("strReadingPoint");
        }
    }

    public class tblICRestrictionMap : EntityTypeConfiguration<tblICRestriction>
    {
        public tblICRestrictionMap()
        {
            // Primary Key
            this.HasKey(t => t.intRestrictionId);

            // Table & Column Mappings
            this.ToTable("tblICRestriction");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intRestrictionId).HasColumnName("intRestrictionId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnLocked).HasColumnName("ysnLocked");
        }
    }

    public class tblICSkuMap : EntityTypeConfiguration<tblICSku>
    {
        public tblICSkuMap()
        {
            // Primary Key
            this.HasKey(t => t.intSKUId);

            // Table & Column Mappings
            this.ToTable("tblICSku");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblWeightPerUnit).HasColumnName("dblWeightPerUnit").HasPrecision(18, 6);
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.dtmProductionDate).HasColumnName("dtmProductionDate");
            this.Property(t => t.dtmReceiveDate).HasColumnName("dtmReceiveDate");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            this.Property(t => t.intParentSKUId).HasColumnName("intParentSKUId");
            this.Property(t => t.intReasonId).HasColumnName("intReasonId");
            this.Property(t => t.intSKUId).HasColumnName("intSKUId");
            this.Property(t => t.intSKUStatusId).HasColumnName("intSKUStatusId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            this.Property(t => t.intWeightPerUnitMeasureId).HasColumnName("intWeightPerUnitMeasureId");
            this.Property(t => t.strBatch).HasColumnName("strBatch");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.strLotCode).HasColumnName("strLotCode");
            this.Property(t => t.strSerialNo).HasColumnName("strSerialNo");
            this.Property(t => t.strSKU).HasColumnName("strSKU");
            this.Property(t => t.ysnSanitized).HasColumnName("ysnSanitized");
        }
    }

    public class tblICEquipmentLengthMap : EntityTypeConfiguration<tblICEquipmentLength>
    {
        public tblICEquipmentLengthMap()
        {
            // Primary Key
            this.HasKey(t => t.intEquipmentLengthId);

            // Table & Column Mappings
            this.ToTable("tblICEquipmentLength");
            this.Property(t => t.intEquipmentLengthId).HasColumnName("intEquipmentLengthId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEquipmentLength).HasColumnName("strEquipmentLength");
        }
    }

}
