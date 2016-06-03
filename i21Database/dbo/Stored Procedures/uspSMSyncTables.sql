CREATE PROCEDURE [dbo].[uspSMSyncTables]
    @remoteDBServer NVARCHAR(MAX),
    @remoteDB NVARCHAR(MAX),
    @remoteDBUserId NVARCHAR(MAX),
    @remoteDBPassword NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

IF EXISTS(SELECT * FROM sys.servers WHERE name = N'REMOTEDBSERVER')
    EXECUTE sp_dropserver 'REMOTEDBSERVER', 'droplogins';

-- IF NOT EXISTS(SELECT * FROM sys.servers WHERE name = N'REMOTEDBSERVER')
EXECUTE sp_addlinkedserver @server = N'REMOTEDBSERVER',
    @srvproduct = N'',
    @provider = N'SQLNCLI',
    @datasrc = @remoteDBServer;
EXECUTE sp_addlinkedsrvlogin 'REMOTEDBSERVER', 'false', NULL, @remoteDBUserId, @remoteDBPassword;

IF @remoteDBServer IS NOT NULL
BEGIN

    -- tblEMEntity
    SET @SQLString = N'EXEC(''MERGE tblEMEntity AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblEMEntity) AS Source
        ON (Target.intEntityId = Source.intEntityId)
        WHEN MATCHED THEN
            UPDATE SET Target.strName = Source.strName, Target.strEmail = Source.strEmail, Target.strWebsite = Source.strWebsite, Target.strInternalNotes = Source.strInternalNotes, Target.ysnPrint1099 = Source.ysnPrint1099, Target.str1099Name = Source.str1099Name, Target.str1099Form = Source.str1099Form, Target.str1099Type = Source.str1099Type, Target.strFederalTaxId = Source.strFederalTaxId, Target.dtmW9Signed = Source.dtmW9Signed, Target.imgPhoto = Source.imgPhoto, Target.strContactNumber = Source.strContactNumber, Target.strTitle = Source.strTitle, Target.strDepartment = Source.strDepartment, Target.strMobile = Source.strMobile, Target.strPhone = Source.strPhone, Target.strPhone2 = Source.strPhone2, Target.strEmail2 = Source.strEmail2, Target.strFax = Source.strFax, Target.strNotes = Source.strNotes, Target.strContactMethod = Source.strContactMethod, Target.strTimezone = Source.strTimezone, Target.strEntityNo = Source.strEntityNo, Target.strContactType = Source.strContactType, Target.strLinkedIn = Source.strLinkedIn, Target.strTwitter = Source.strTwitter, Target.strFacebook = Source.strFacebook, Target.intDefaultLocationId = Source.intDefaultLocationId, Target.ysnActive = Source.ysnActive, Target.ysnReceiveEmail = Source.ysnReceiveEmail, Target.strEmailDistributionOption = Source.strEmailDistributionOption, Target.dtmOriginationDate = Source.dtmOriginationDate, Target.strPhoneBackUp = Source.strPhoneBackUp, Target.intDefaultCountryId = Source.intDefaultCountryId, Target.strDocumentDelivery = Source.strDocumentDelivery, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intEntityId, strName, strEmail, strWebsite, strInternalNotes, ysnPrint1099, str1099Name, str1099Form, str1099Type, strFederalTaxId, dtmW9Signed, imgPhoto, strContactNumber, strTitle, strDepartment, strMobile, strPhone, strPhone2, strEmail2, strFax, strNotes, strContactMethod, strTimezone, strEntityNo, strContactType, strLinkedIn, strTwitter, strFacebook, intDefaultLocationId, ysnActive, ysnReceiveEmail, strEmailDistributionOption, dtmOriginationDate, strPhoneBackUp, intDefaultCountryId, strDocumentDelivery, intConcurrencyId)
            VALUES (Source.intEntityId, Source.strName, Source.strEmail, Source.strWebsite, Source.strInternalNotes, Source.ysnPrint1099, Source.str1099Name, Source.str1099Form, Source.str1099Type, Source.strFederalTaxId, Source.dtmW9Signed, Source.imgPhoto, Source.strContactNumber, Source.strTitle, Source.strDepartment, Source.strMobile, Source.strPhone, Source.strPhone2, Source.strEmail2, Source.strFax, Source.strNotes, Source.strContactMethod, Source.strTimezone, Source.strEntityNo, Source.strContactType, Source.strLinkedIn, Source.strTwitter, Source.strFacebook, Source.intDefaultLocationId, Source.ysnActive, Source.ysnReceiveEmail, Source.strEmailDistributionOption, Source.dtmOriginationDate, Source.strPhoneBackUp, Source.intDefaultCountryId, Source.strDocumentDelivery, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblEMEntity ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblEMEntity OFF

    -- tblEMEntityCredential
    SET @SQLString = N'EXEC(''MERGE tblEMEntityCredential AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblEMEntityCredential) AS Source
        ON (Target.intEntityCredentialId = Source.intEntityCredentialId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strUserName = Source.strUserName, Target.strPassword = Source.strPassword, Target.strApiKey = Source.strApiKey, Target.strApiSecret = Source.strApiSecret, Target.ysnApiDisabled = Source.ysnApiDisabled, Target.strTFASecretKey = Source.strTFASecretKey, Target.strTFACurrentCode = Source.strTFACurrentCode, Target.strTFACodeNotifMedium = Source.strTFACodeNotifMedium, Target.ysnTFAEnabled = Source.ysnTFAEnabled, Target.ysnNotEncrypted = Source.ysnNotEncrypted, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intEntityCredentialId, intEntityId, strUserName, strPassword, strApiKey, strApiSecret, ysnApiDisabled, strTFASecretKey, strTFACurrentCode, strTFACodeNotifMedium, ysnTFAEnabled, ysnNotEncrypted, intConcurrencyId)
            VALUES (Source.intEntityCredentialId, Source.intEntityId, Source.strUserName, Source.strPassword, Source.strApiKey, Source.strApiSecret, Source.ysnApiDisabled, Source.strTFASecretKey, Source.strTFACurrentCode, Source.strTFACodeNotifMedium, Source.ysnTFAEnabled, Source.ysnNotEncrypted, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblEMEntityCredential ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblEMEntityCredential OFF

    -- tblEMEntityLocation
    SET @SQLString = N'EXEC(''MERGE tblEMEntityLocation AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblEMEntityLocation) AS Source
        ON (Target.intEntityLocationId = Source.intEntityLocationId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strLocationName = Source.strLocationName, Target.strAddress = Source.strAddress, Target.strCity = Source.strCity, Target.strCountry = Source.strCountry, Target.strState = Source.strState, Target.strZipCode = Source.strZipCode, Target.strPhone = Source.strPhone, Target.strFax = Source.strFax, Target.strPricingLevel = Source.strPricingLevel, Target.strNotes = Source.strNotes, Target.intShipViaId = Source.intShipViaId, Target.intTermsId = Source.intTermsId, Target.intWarehouseId = Source.intWarehouseId, Target.ysnDefaultLocation = Source.ysnDefaultLocation, Target.intFreightTermId = Source.intFreightTermId, Target.intCountyTaxCodeId = Source.intCountyTaxCodeId, Target.intTaxGroupId = Source.intTaxGroupId, Target.intTaxClassId = Source.intTaxClassId, Target.ysnActive = Source.ysnActive, Target.dblLongitude = Source.dblLongitude, Target.dblLatitude = Source.dblLatitude, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intEntityLocationId, intEntityId, strLocationName, strAddress, strCity, strCountry, strState, strZipCode, strPhone, strFax, strPricingLevel, strNotes, intShipViaId, intTermsId, intWarehouseId, ysnDefaultLocation, intFreightTermId, intCountyTaxCodeId, intTaxGroupId, intTaxClassId, ysnActive, dblLongitude, dblLatitude, intConcurrencyId)
            VALUES (Source.intEntityLocationId, Source.intEntityId, Source.strLocationName, Source.strAddress, Source.strCity, Source.strCountry, Source.strState, Source.strZipCode, Source.strPhone, Source.strFax, Source.strPricingLevel, Source.strNotes, Source.intShipViaId, Source.intTermsId, Source.intWarehouseId, Source.ysnDefaultLocation, Source.intFreightTermId, Source.intCountyTaxCodeId, Source.intTaxGroupId, Source.intTaxClassId, Source.ysnActive, Source.dblLongitude, Source.dblLatitude, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblEMEntityLocation ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblEMEntityLocation OFF

    -- tblSMUserSecurity
    SET @SQLString = N'EXEC(''MERGE tblSMUserSecurity AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSMUserSecurity) AS Source
        ON (Target.intEntityUserSecurityId = Source.intEntityUserSecurityId)
        WHEN MATCHED THEN
            UPDATE SET Target.intUserRoleID = Source.intUserRoleID, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intSecurityPolicyId = Source.intSecurityPolicyId, Target.strUserName = Source.strUserName, Target.strJIRAUserName = Source.strJIRAUserName, Target.strFullName = Source.strFullName, Target.strPassword = Source.strPassword, Target.strOverridePassword = Source.strOverridePassword, Target.strDashboardRole = Source.strDashboardRole, Target.strFirstName = Source.strFirstName, Target.strMiddleName = Source.strMiddleName, Target.strLastName = Source.strLastName, Target.strPhone = Source.strPhone, Target.strDepartment = Source.strDepartment, Target.strLocation = Source.strLocation, Target.strEmail = Source.strEmail, Target.strMenuPermission = Source.strMenuPermission, Target.strMenu = Source.strMenu, Target.strForm = Source.strForm, Target.strFavorite = Source.strFavorite, Target.ysnDisabled = Source.ysnDisabled, Target.ysnAdmin = Source.ysnAdmin, Target.ysnRequirePurchasingApproval = Source.ysnRequirePurchasingApproval, Target.strDateFormat = Source.strDateFormat, Target.strNumberFormat = Source.strNumberFormat, Target.dtmLastChangePassword = Source.dtmLastChangePassword, Target.intInvalidAttempt = Source.intInvalidAttempt, Target.ysnLockedOut = Source.ysnLockedOut, Target.dtmLockOutTime = Source.dtmLockOutTime, Target.intConcurrencyId = Source.intConcurrencyId, Target.intEntityIdOld = Source.intEntityIdOld, Target.intUserSecurityIdOld = Source.intUserSecurityIdOld
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intEntityUserSecurityId, intUserRoleID, intCompanyLocationId, intSecurityPolicyId, strUserName, strJIRAUserName, strFullName, strPassword, strOverridePassword, strDashboardRole, strFirstName, strMiddleName, strLastName, strPhone, strDepartment, strLocation, strEmail, strMenuPermission, strMenu, strForm, strFavorite, ysnDisabled, ysnAdmin, ysnRequirePurchasingApproval, strDateFormat, strNumberFormat, dtmLastChangePassword, intInvalidAttempt, ysnLockedOut, dtmLockOutTime, intConcurrencyId, intEntityIdOld, intUserSecurityIdOld)
            VALUES (Source.intEntityUserSecurityId, Source.intUserRoleID, Source.intCompanyLocationId, Source.intSecurityPolicyId, Source.strUserName, Source.strJIRAUserName, Source.strFullName, Source.strPassword, Source.strOverridePassword, Source.strDashboardRole, Source.strFirstName, Source.strMiddleName, Source.strLastName, Source.strPhone, Source.strDepartment, Source.strLocation, Source.strEmail, Source.strMenuPermission, Source.strMenu, Source.strForm, Source.strFavorite, Source.ysnDisabled, Source.ysnAdmin, Source.ysnRequirePurchasingApproval, Source.strDateFormat, Source.strNumberFormat, Source.dtmLastChangePassword, Source.intInvalidAttempt, Source.ysnLockedOut, Source.dtmLockOutTime, Source.intConcurrencyId, Source.intEntityIdOld, Source.intUserSecurityIdOld)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageType
    SET @SQLString = N'EXEC(''MERGE tblGRStorageType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRStorageType) AS Source
        ON (Target.intStorageScheduleTypeId = Source.intStorageScheduleTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.strStorageTypeDescription = Source.strStorageTypeDescription, Target.strStorageTypeCode = Source.strStorageTypeCode, Target.ysnReceiptedStorage = Source.ysnReceiptedStorage, Target.intConcurrencyId = Source.intConcurrencyId, Target.strOwnedPhysicalStock = Source.strOwnedPhysicalStock, Target.ysnDPOwnedType = Source.ysnDPOwnedType, Target.ysnGrainBankType = Source.ysnGrainBankType, Target.ysnActive = Source.ysnActive, Target.ysnCustomerStorage = Source.ysnCustomerStorage
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageScheduleTypeId, strStorageTypeDescription, strStorageTypeCode, ysnReceiptedStorage, intConcurrencyId, strOwnedPhysicalStock, ysnDPOwnedType, ysnGrainBankType, ysnActive, ysnCustomerStorage)
            VALUES (Source.intStorageScheduleTypeId, Source.strStorageTypeDescription, Source.strStorageTypeCode, Source.ysnReceiptedStorage, Source.intConcurrencyId, Source.strOwnedPhysicalStock, Source.ysnDPOwnedType, Source.ysnGrainBankType, Source.ysnActive, Source.ysnCustomerStorage)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRStorageType ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageType OFF

    -- tblGRStorageScheduleLocationUse
    SET @SQLString = N'EXEC(''MERGE tblGRStorageScheduleLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRStorageScheduleLocationUse) AS Source
        ON (Target.intStorageScheduleLocationUseId = Source.intStorageScheduleLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageScheduleId = Source.intStorageScheduleId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.ysnStorageScheduleLocationActive = Source.ysnStorageScheduleLocationActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageScheduleLocationUseId, intStorageScheduleId, intCompanyLocationId, ysnStorageScheduleLocationActive, intConcurrencyId)
            VALUES (Source.intStorageScheduleLocationUseId, Source.intStorageScheduleId, Source.intCompanyLocationId, Source.ysnStorageScheduleLocationActive, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRStorageScheduleLocationUse ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageScheduleLocationUse OFF

    -- tblGRStorageSchedulePeriod
    SET @SQLString = N'EXEC(''MERGE tblGRStorageSchedulePeriod AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRStorageSchedulePeriod) AS Source
        ON (Target.intStorageSchedulePeriodId = Source.intStorageSchedulePeriodId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intStorageScheduleRule = Source.intStorageScheduleRule, Target.strPeriodType = Source.strPeriodType, Target.dtmEffectiveDate = Source.dtmEffectiveDate, Target.dtmEndingDate = Source.dtmEndingDate, Target.intNumberOfDays = Source.intNumberOfDays, Target.dblStorageRate = Source.dblStorageRate, Target.strFeeDescription = Source.strFeeDescription, Target.dblFeeRate = Source.dblFeeRate, Target.strFeeType = Source.strFeeType, Target.intSort = Source.intSort
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageSchedulePeriodId, intConcurrencyId, intStorageScheduleRule, strPeriodType, dtmEffectiveDate, dtmEndingDate, intNumberOfDays, dblStorageRate, strFeeDescription, dblFeeRate, strFeeType, intSort)
            VALUES (Source.intStorageSchedulePeriodId, Source.intConcurrencyId, Source.intStorageScheduleRule, Source.strPeriodType, Source.dtmEffectiveDate, Source.dtmEndingDate, Source.intNumberOfDays, Source.dblStorageRate, Source.strFeeDescription, Source.dblFeeRate, Source.strFeeType, Source.intSort)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRStorageSchedulePeriod ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageSchedulePeriod OFF

    -- tblGRStorageScheduleRule
    SET @SQLString = N'EXEC(''MERGE tblGRStorageScheduleRule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRStorageScheduleRule) AS Source
        ON (Target.intStorageScheduleRuleId = Source.intStorageScheduleRuleId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.strScheduleDescription = Source.strScheduleDescription, Target.intStorageType = Source.intStorageType, Target.intCommodity = Source.intCommodity, Target.intAllowanceDays = Source.intAllowanceDays, Target.dtmEffectiveDate = Source.dtmEffectiveDate, Target.dtmTerminationDate = Source.dtmTerminationDate, Target.dblFeeRate = Source.dblFeeRate, Target.strFeeType = Source.strFeeType, Target.intCurrencyID = Source.intCurrencyID, Target.strScheduleId = Source.strScheduleId, Target.strStorageRate = Source.strStorageRate, Target.strFirstMonth = Source.strFirstMonth, Target.strLastMonth = Source.strLastMonth, Target.strAllowancePeriod = Source.strAllowancePeriod, Target.dtmAllowancePeriodFrom = Source.dtmAllowancePeriodFrom, Target.dtmAllowancePeriodTo = Source.dtmAllowancePeriodTo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageScheduleRuleId, intConcurrencyId, strScheduleDescription, intStorageType, intCommodity, intAllowanceDays, dtmEffectiveDate, dtmTerminationDate, dblFeeRate, strFeeType, intCurrencyID, strScheduleId, strStorageRate, strFirstMonth, strLastMonth, strAllowancePeriod, dtmAllowancePeriodFrom, dtmAllowancePeriodTo)
            VALUES (Source.intStorageScheduleRuleId, Source.intConcurrencyId, Source.strScheduleDescription, Source.intStorageType, Source.intCommodity, Source.intAllowanceDays, Source.dtmEffectiveDate, Source.dtmTerminationDate, Source.dblFeeRate, Source.strFeeType, Source.intCurrencyID, Source.strScheduleId, Source.strStorageRate, Source.strFirstMonth, Source.strLastMonth, Source.strAllowancePeriod, Source.dtmAllowancePeriodFrom, Source.dtmAllowancePeriodTo)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRStorageScheduleRule ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageScheduleRule OFF

    -- tblGRDiscountSchedule
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountSchedule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountSchedule) AS Source
        ON (Target.intDiscountScheduleId = Source.intDiscountScheduleId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCurrencyId = Source.intCurrencyId, Target.intCommodityId = Source.intCommodityId, Target.strDiscountDescription = Source.strDiscountDescription, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDiscountScheduleId, intCurrencyId, intCommodityId, strDiscountDescription, intConcurrencyId)
            VALUES (Source.intDiscountScheduleId, Source.intCurrencyId, Source.intCommodityId, Source.strDiscountDescription, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRDiscountSchedule ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountSchedule OFF

    -- tblGRDiscountScheduleCode
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountScheduleCode AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountScheduleCode) AS Source
        ON (Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountScheduleId = Source.intDiscountScheduleId, Target.intDiscountCalculationOptionId = Source.intDiscountCalculationOptionId, Target.intShrinkCalculationOptionId = Source.intShrinkCalculationOptionId, Target.ysnZeroIsValid = Source.ysnZeroIsValid, Target.dblMinimumValue = Source.dblMinimumValue, Target.dblMaximumValue = Source.dblMaximumValue, Target.dblDefaultValue = Source.dblDefaultValue, Target.ysnQualityDiscount = Source.ysnQualityDiscount, Target.ysnDryingDiscount = Source.ysnDryingDiscount, Target.dtmEffectiveDate = Source.dtmEffectiveDate, Target.dtmTerminationDate = Source.dtmTerminationDate, Target.intConcurrencyId = Source.intConcurrencyId, Target.intSort = Source.intSort, Target.strDiscountChargeType = Source.strDiscountChargeType, Target.intItemId = Source.intItemId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDiscountScheduleCodeId, intDiscountScheduleId, intDiscountCalculationOptionId, intShrinkCalculationOptionId, ysnZeroIsValid, dblMinimumValue, dblMaximumValue, dblDefaultValue, ysnQualityDiscount, ysnDryingDiscount, dtmEffectiveDate, dtmTerminationDate, intConcurrencyId, intSort, strDiscountChargeType, intItemId)
            VALUES (Source.intDiscountScheduleCodeId, Source.intDiscountScheduleId, Source.intDiscountCalculationOptionId, Source.intShrinkCalculationOptionId, Source.ysnZeroIsValid, Source.dblMinimumValue, Source.dblMaximumValue, Source.dblDefaultValue, Source.ysnQualityDiscount, Source.ysnDryingDiscount, Source.dtmEffectiveDate, Source.dtmTerminationDate, Source.intConcurrencyId, Source.intSort, Source.strDiscountChargeType, Source.intItemId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRDiscountScheduleCode ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountScheduleCode OFF

    -- tblGRDiscountScheduleLine
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountScheduleLine AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountScheduleLine) AS Source
        ON (Target.intDiscountScheduleLineId = Source.intDiscountScheduleLineId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.dblRangeStartingValue = Source.dblRangeStartingValue, Target.dblRangeEndingValue = Source.dblRangeEndingValue, Target.dblIncrementValue = Source.dblIncrementValue, Target.dblDiscountValue = Source.dblDiscountValue, Target.dblShrinkValue = Source.dblShrinkValue, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDiscountScheduleLineId, intDiscountScheduleCodeId, dblRangeStartingValue, dblRangeEndingValue, dblIncrementValue, dblDiscountValue, dblShrinkValue, intConcurrencyId)
            VALUES (Source.intDiscountScheduleLineId, Source.intDiscountScheduleCodeId, Source.dblRangeStartingValue, Source.dblRangeEndingValue, Source.dblIncrementValue, Source.dblDiscountValue, Source.dblShrinkValue, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRDiscountScheduleLine ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountScheduleLine OFF

    -- tblGRDiscountCalculationOption
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountCalculationOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountCalculationOption) AS Source
        ON (Target.intValueFieldId = Source.intValueFieldId)
        WHEN MATCHED THEN
            UPDATE SET Target.strDisplayField = Source.strDisplayField, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intValueFieldId, strDisplayField, intConcurrencyId)
            VALUES (Source.intValueFieldId, Source.strDisplayField, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountCrossReference
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountCrossReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountCrossReference) AS Source
        ON (Target.intDiscountCrossReferenceId = Source.intDiscountCrossReferenceId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountId = Source.intDiscountId, Target.intDiscountScheduleId = Source.intDiscountScheduleId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDiscountCrossReferenceId, intDiscountId, intDiscountScheduleId, intConcurrencyId)
            VALUES (Source.intDiscountCrossReferenceId, Source.intDiscountId, Source.intDiscountScheduleId, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRDiscountCrossReference ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountCrossReference OFF

    -- tblGRDiscountId
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountId AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountId) AS Source
        ON (Target.intDiscountId = Source.intDiscountId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCurrencyId = Source.intCurrencyId, Target.strDiscountId = Source.strDiscountId, Target.strDiscountDescription = Source.strDiscountDescription, Target.ysnDiscountIdActive = Source.ysnDiscountIdActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDiscountId, intCurrencyId, strDiscountId, strDiscountDescription, ysnDiscountIdActive, intConcurrencyId)
            VALUES (Source.intDiscountId, Source.intCurrencyId, Source.strDiscountId, Source.strDiscountDescription, Source.ysnDiscountIdActive, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRDiscountId ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountId OFF

    -- tblGRDiscountLocationUse
    SET @SQLString = N'EXEC(''MERGE tblGRDiscountLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblGRDiscountLocationUse) AS Source
        ON (Target.intDiscountLocationUseId = Source.intDiscountLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountId = Source.intDiscountId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.ysnDiscountLocationActive = Source.ysnDiscountLocationActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDiscountLocationUseId, intDiscountId, intCompanyLocationId, ysnDiscountLocationActive, intConcurrencyId)
            VALUES (Source.intDiscountLocationUseId, Source.intDiscountId, Source.intCompanyLocationId, Source.ysnDiscountLocationActive, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblGRDiscountLocationUse ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountLocationUse OFF

    -- tblCTContractHeader
    SET @SQLString = N'MERGE tblCTContractHeader AS Target
        USING (SELECT * FROM REMOTEDBSERVER.repDB.dbo.tblCTContractHeader) AS Source
        ON (Target.intContractHeaderId = Source.intContractHeaderId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intContractTypeId = Source.intContractTypeId, Target.intEntityId = Source.intEntityId, Target.intEntityContactId = Source.intEntityContactId, Target.intContractPlanId = Source.intContractPlanId, Target.intCommodityId = Source.intCommodityId, Target.dblQuantity = Source.dblQuantity, Target.intCommodityUOMId = Source.intCommodityUOMId, Target.strContractNumber = Source.strContractNumber, Target.dtmContractDate = Source.dtmContractDate, Target.strCustomerContract = Source.strCustomerContract, Target.dtmDeferPayDate = Source.dtmDeferPayDate, Target.dblDeferPayRate = Source.dblDeferPayRate, Target.intContractTextId = Source.intContractTextId, Target.ysnSigned = Source.ysnSigned, Target.dtmSigned = Source.dtmSigned, Target.ysnPrinted = Source.ysnPrinted, Target.intSalespersonId = Source.intSalespersonId, Target.intGradeId = Source.intGradeId, Target.intWeightId = Source.intWeightId, Target.intCropYearId = Source.intCropYearId, Target.strInternalComment = Source.strInternalComment, Target.strPrintableRemarks = Source.strPrintableRemarks, Target.intAssociationId = Source.intAssociationId, Target.intTermId = Source.intTermId, Target.intPricingTypeId = Source.intPricingTypeId, Target.intApprovalBasisId = Source.intApprovalBasisId, Target.intContractBasisId = Source.intContractBasisId, Target.intPositionId = Source.intPositionId, Target.intInsuranceById = Source.intInsuranceById, Target.intInvoiceTypeId = Source.intInvoiceTypeId, Target.dblTolerancePct = Source.dblTolerancePct, Target.dblProvisionalInvoicePct = Source.dblProvisionalInvoicePct, Target.ysnSubstituteItem = Source.ysnSubstituteItem, Target.ysnUnlimitedQuantity = Source.ysnUnlimitedQuantity, Target.ysnMaxPrice = Source.ysnMaxPrice, Target.intINCOLocationTypeId = Source.intINCOLocationTypeId, Target.intCountryId = Source.intCountryId, Target.intCompanyLocationPricingLevelId = Source.intCompanyLocationPricingLevelId, Target.ysnProvisional = Source.ysnProvisional, Target.ysnLoad = Source.ysnLoad, Target.intNoOfLoad = Source.intNoOfLoad, Target.dblQuantityPerLoad = Source.dblQuantityPerLoad, Target.intLoadUOMId = Source.intLoadUOMId, Target.ysnCategory = Source.ysnCategory, Target.ysnMultiplePriceFixation = Source.ysnMultiplePriceFixation, Target.intCategoryUnitMeasureId = Source.intCategoryUnitMeasureId, Target.intLoadCategoryUnitMeasureId = Source.intLoadCategoryUnitMeasureId, Target.intArbitrationId = Source.intArbitrationId, Target.intProducerId = Source.intProducerId, Target.ysnExported = Source.ysnExported, Target.dtmExported = Source.dtmExported, Target.intCreatedById = Source.intCreatedById, Target.dtmCreated = Source.dtmCreated, Target.intLastModifiedById = Source.intLastModifiedById, Target.dtmLastModified = Source.dtmLastModified
             WHEN NOT MATCHED BY TARGET THEN
             INSERT (intContractHeaderId, intConcurrencyId, intContractTypeId, intEntityId, intEntityContactId, intContractPlanId, intCommodityId, dblQuantity, intCommodityUOMId, strContractNumber, dtmContractDate, strCustomerContract, dtmDeferPayDate, dblDeferPayRate, intContractTextId, ysnSigned, dtmSigned, ysnPrinted, intSalespersonId, intGradeId, intWeightId, intCropYearId, strInternalComment, strPrintableRemarks, intAssociationId, intTermId, intPricingTypeId, intApprovalBasisId, intContractBasisId, intPositionId, intInsuranceById, intInvoiceTypeId, dblTolerancePct, dblProvisionalInvoicePct, ysnSubstituteItem, ysnUnlimitedQuantity, ysnMaxPrice, intINCOLocationTypeId, intCountryId, intCompanyLocationPricingLevelId, ysnProvisional, ysnLoad, intNoOfLoad, dblQuantityPerLoad, intLoadUOMId, ysnCategory, ysnMultiplePriceFixation, intCategoryUnitMeasureId, intLoadCategoryUnitMeasureId, intArbitrationId, intProducerId, ysnExported, dtmExported, intCreatedById, dtmCreated, intLastModifiedById, dtmLastModified)
             VALUES (Source.intContractHeaderId, Source.intConcurrencyId, Source.intContractTypeId, Source.intEntityId, Source.intEntityContactId, Source.intContractPlanId, Source.intCommodityId, Source.dblQuantity, Source.intCommodityUOMId, Source.strContractNumber, Source.dtmContractDate, Source.strCustomerContract, Source.dtmDeferPayDate, Source.dblDeferPayRate, Source.intContractTextId, Source.ysnSigned, Source.dtmSigned, Source.ysnPrinted, Source.intSalespersonId, Source.intGradeId, Source.intWeightId, Source.intCropYearId, Source.strInternalComment, Source.strPrintableRemarks, Source.intAssociationId, Source.intTermId, Source.intPricingTypeId, Source.intApprovalBasisId, Source.intContractBasisId, Source.intPositionId, Source.intInsuranceById, Source.intInvoiceTypeId, Source.dblTolerancePct, Source.dblProvisionalInvoicePct, Source.ysnSubstituteItem, Source.ysnUnlimitedQuantity, Source.ysnMaxPrice, Source.intINCOLocationTypeId, Source.intCountryId, Source.intCompanyLocationPricingLevelId, Source.ysnProvisional, Source.ysnLoad, Source.intNoOfLoad, Source.dblQuantityPerLoad, Source.intLoadUOMId, Source.ysnCategory, Source.ysnMultiplePriceFixation, Source.intCategoryUnitMeasureId, Source.intLoadCategoryUnitMeasureId, Source.intArbitrationId, Source.intProducerId, Source.ysnExported, Source.dtmExported, Source.intCreatedById, Source.dtmCreated, Source.intLastModifiedById, Source.dtmLastModified)
             WHEN NOT MATCHED BY SOURCE THEN
             DELETE;';

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    SET IDENTITY_INSERT tblCTContractHeader ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractHeader OFF

    -- tblCTContractDetail
    SET @SQLString = N'EXEC(''MERGE tblCTContractDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblCTContractDetail) AS Source
        ON (Target.intContractDetailId = Source.intContractDetailId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intContractHeaderId = Source.intContractHeaderId, Target.intContractStatusId = Source.intContractStatusId, Target.intContractSeq = Source.intContractSeq, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.dtmStartDate = Source.dtmStartDate, Target.dtmEndDate = Source.dtmEndDate, Target.intFreightTermId = Source.intFreightTermId, Target.intShipViaId = Source.intShipViaId, Target.intItemContractId = Source.intItemContractId, Target.intItemId = Source.intItemId, Target.intCategoryId = Source.intCategoryId, Target.dblQuantity = Source.dblQuantity, Target.intItemUOMId = Source.intItemUOMId, Target.dblOriginalQty = Source.dblOriginalQty, Target.dblBalance = Source.dblBalance, Target.dblIntransitQty = Source.dblIntransitQty, Target.dblScheduleQty = Source.dblScheduleQty, Target.dblNetWeight = Source.dblNetWeight, Target.intNetWeightUOMId = Source.intNetWeightUOMId, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.intCategoryUOMId = Source.intCategoryUOMId, Target.intNoOfLoad = Source.intNoOfLoad, Target.dblQuantityPerLoad = Source.dblQuantityPerLoad, Target.intIndexId = Source.intIndexId, Target.dblAdjustment = Source.dblAdjustment, Target.intAdjItemUOMId = Source.intAdjItemUOMId, Target.intPricingTypeId = Source.intPricingTypeId, Target.intFutureMarketId = Source.intFutureMarketId, Target.intFutureMonthId = Source.intFutureMonthId, Target.dblFutures = Source.dblFutures, Target.dblBasis = Source.dblBasis, Target.dblOriginalBasis = Source.dblOriginalBasis, Target.dblCashPrice = Source.dblCashPrice, Target.dblTotalCost = Source.dblTotalCost, Target.intCurrencyId = Source.intCurrencyId, Target.intPriceItemUOMId = Source.intPriceItemUOMId, Target.dblNoOfLots = Source.dblNoOfLots, Target.intMarketZoneId = Source.intMarketZoneId, Target.intDiscountTypeId = Source.intDiscountTypeId, Target.intDiscountId = Source.intDiscountId, Target.intDiscountScheduleId = Source.intDiscountScheduleId, Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.intStorageScheduleRuleId = Source.intStorageScheduleRuleId, Target.intContractOptHeaderId = Source.intContractOptHeaderId, Target.strBuyerSeller = Source.strBuyerSeller, Target.intBillTo = Source.intBillTo, Target.intFreightRateId = Source.intFreightRateId, Target.strFobBasis = Source.strFobBasis, Target.intRailGradeId = Source.intRailGradeId, Target.strRailRemark = Source.strRailRemark, Target.strLoadingPointType = Source.strLoadingPointType, Target.intLoadingPortId = Source.intLoadingPortId, Target.strDestinationPointType = Source.strDestinationPointType, Target.intDestinationPortId = Source.intDestinationPortId, Target.strShippingTerm = Source.strShippingTerm, Target.intShippingLineId = Source.intShippingLineId, Target.strVessel = Source.strVessel, Target.intDestinationCityId = Source.intDestinationCityId, Target.intShipperId = Source.intShipperId, Target.strRemark = Source.strRemark, Target.intFarmFieldId = Source.intFarmFieldId, Target.strGrade = Source.strGrade, Target.strVendorLotID = Source.strVendorLotID, Target.strInvoiceNo = Source.strInvoiceNo, Target.strReference = Source.strReference, Target.intUnitsPerLayer = Source.intUnitsPerLayer, Target.intLayersPerPallet = Source.intLayersPerPallet, Target.dtmEventStartDate = Source.dtmEventStartDate, Target.dtmPlannedAvailabilityDate = Source.dtmPlannedAvailabilityDate, Target.dtmUpdatedAvailabilityDate = Source.dtmUpdatedAvailabilityDate, Target.intBookId = Source.intBookId, Target.intSubBookId = Source.intSubBookId, Target.intContainerTypeId = Source.intContainerTypeId, Target.intNumberOfContainers = Source.intNumberOfContainers, Target.intInvoiceCurrencyId = Source.intInvoiceCurrencyId, Target.dtmFXValidFrom = Source.dtmFXValidFrom, Target.dtmFXValidTo = Source.dtmFXValidTo, Target.dblRate = Source.dblRate, Target.intFXPriceUOMId = Source.intFXPriceUOMId, Target.strFXRemarks = Source.strFXRemarks, Target.dblAssumedFX = Source.dblAssumedFX, Target.strFixationBy = Source.strFixationBy, Target.strPackingDescription = Source.strPackingDescription, Target.intCurrencyExchangeRateId = Source.intCurrencyExchangeRateId, Target.intCreatedById = Source.intCreatedById, Target.dtmCreated = Source.dtmCreated, Target.intLastModifiedById = Source.intLastModifiedById, Target.dtmLastModified = Source.dtmLastModified
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intContractDetailId, intConcurrencyId, intContractHeaderId, intContractStatusId, intContractSeq, intCompanyLocationId, dtmStartDate, dtmEndDate, intFreightTermId, intShipViaId, intItemContractId, intItemId, intCategoryId, dblQuantity, intItemUOMId, dblOriginalQty, dblBalance, dblIntransitQty, dblScheduleQty, dblNetWeight, intNetWeightUOMId, intUnitMeasureId, intCategoryUOMId, intNoOfLoad, dblQuantityPerLoad, intIndexId, dblAdjustment, intAdjItemUOMId, intPricingTypeId, intFutureMarketId, intFutureMonthId, dblFutures, dblBasis, dblOriginalBasis, dblCashPrice, dblTotalCost, intCurrencyId, intPriceItemUOMId, dblNoOfLots, intMarketZoneId, intDiscountTypeId, intDiscountId, intDiscountScheduleId, intDiscountScheduleCodeId, intStorageScheduleRuleId, intContractOptHeaderId, strBuyerSeller, intBillTo, intFreightRateId, strFobBasis, intRailGradeId, strRailRemark, strLoadingPointType, intLoadingPortId, strDestinationPointType, intDestinationPortId, strShippingTerm, intShippingLineId, strVessel, intDestinationCityId, intShipperId, strRemark, intFarmFieldId, strGrade, strVendorLotID, strInvoiceNo, strReference, intUnitsPerLayer, intLayersPerPallet, dtmEventStartDate, dtmPlannedAvailabilityDate, dtmUpdatedAvailabilityDate, intBookId, intSubBookId, intContainerTypeId, intNumberOfContainers, intInvoiceCurrencyId, dtmFXValidFrom, dtmFXValidTo, dblRate, intFXPriceUOMId, strFXRemarks, dblAssumedFX, strFixationBy, strPackingDescription, intCurrencyExchangeRateId, intCreatedById, dtmCreated, intLastModifiedById, dtmLastModified)
            VALUES (Source.intContractDetailId, Source.intConcurrencyId, Source.intContractHeaderId, Source.intContractStatusId, Source.intContractSeq, Source.intCompanyLocationId, Source.dtmStartDate, Source.dtmEndDate, Source.intFreightTermId, Source.intShipViaId, Source.intItemContractId, Source.intItemId, Source.intCategoryId, Source.dblQuantity, Source.intItemUOMId, Source.dblOriginalQty, Source.dblBalance, Source.dblIntransitQty, Source.dblScheduleQty, Source.dblNetWeight, Source.intNetWeightUOMId, Source.intUnitMeasureId, Source.intCategoryUOMId, Source.intNoOfLoad, Source.dblQuantityPerLoad, Source.intIndexId, Source.dblAdjustment, Source.intAdjItemUOMId, Source.intPricingTypeId, Source.intFutureMarketId, Source.intFutureMonthId, Source.dblFutures, Source.dblBasis, Source.dblOriginalBasis, Source.dblCashPrice, Source.dblTotalCost, Source.intCurrencyId, Source.intPriceItemUOMId, Source.dblNoOfLots, Source.intMarketZoneId, Source.intDiscountTypeId, Source.intDiscountId, Source.intDiscountScheduleId, Source.intDiscountScheduleCodeId, Source.intStorageScheduleRuleId, Source.intContractOptHeaderId, Source.strBuyerSeller, Source.intBillTo, Source.intFreightRateId, Source.strFobBasis, Source.intRailGradeId, Source.strRailRemark, Source.strLoadingPointType, Source.intLoadingPortId, Source.strDestinationPointType, Source.intDestinationPortId, Source.strShippingTerm, Source.intShippingLineId, Source.strVessel, Source.intDestinationCityId, Source.intShipperId, Source.strRemark, Source.intFarmFieldId, Source.strGrade, Source.strVendorLotID, Source.strInvoiceNo, Source.strReference, Source.intUnitsPerLayer, Source.intLayersPerPallet, Source.dtmEventStartDate, Source.dtmPlannedAvailabilityDate, Source.dtmUpdatedAvailabilityDate, Source.intBookId, Source.intSubBookId, Source.intContainerTypeId, Source.intNumberOfContainers, Source.intInvoiceCurrencyId, Source.dtmFXValidFrom, Source.dtmFXValidTo, Source.dblRate, Source.intFXPriceUOMId, Source.strFXRemarks, Source.dblAssumedFX, Source.strFixationBy, Source.strPackingDescription, Source.intCurrencyExchangeRateId, Source.intCreatedById, Source.dtmCreated, Source.intLastModifiedById, Source.dtmLastModified)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblCTContractDetail ON
    EXECUTE sp_executesql @SQLString;

    SET IDENTITY_INSERT tblCTContractDetail OFF

    -- tblCTContractCost
    SET @SQLString = N'EXEC(''MERGE tblCTContractCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblCTContractCost) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intContractDetailId = Source.intContractDetailId, Target.intItemId = Source.intItemId, Target.intVendorId = Source.intVendorId, Target.strCostMethod = Source.strCostMethod, Target.intCurrencyId = Source.intCurrencyId, Target.dblRate = Source.dblRate, Target.intItemUOMId = Source.intItemUOMId, Target.dblFX = Source.dblFX, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intContractCostId, intConcurrencyId, intContractDetailId, intItemId, intVendorId, strCostMethod, intCurrencyId, dblRate, intItemUOMId, dblFX, ysnAccrue, ysnMTM, ysnPrice)
            VALUES (Source.intContractCostId, Source.intConcurrencyId, Source.intContractDetailId, Source.intItemId, Source.intVendorId, Source.strCostMethod, Source.intCurrencyId, Source.dblRate, Source.intItemUOMId, Source.dblFX, Source.ysnAccrue, Source.ysnMTM, Source.ysnPrice)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblCTContractCost ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCost OFF

    -- tblLGLoad
    SET @SQLString = N'EXEC(''MERGE tblLGLoad AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblLGLoad) AS Source
        ON (Target.intLoadId = Source.intLoadId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.strLoadNumber = Source.strLoadNumber, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intPurchaseSale = Source.intPurchaseSale, Target.intItemId = Source.intItemId, Target.dblQuantity = Source.dblQuantity, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.dtmScheduledDate = Source.dtmScheduledDate, Target.strCustomerReference = Source.strCustomerReference, Target.intEquipmentTypeId = Source.intEquipmentTypeId, Target.intEntityId = Source.intEntityId, Target.intEntityLocationId = Source.intEntityLocationId, Target.intContractDetailId = Source.intContractDetailId, Target.strComments = Source.strComments, Target.intHaulerEntityId = Source.intHaulerEntityId, Target.intTicketId = Source.intTicketId, Target.ysnInProgress = Source.ysnInProgress, Target.dblDeliveredQuantity = Source.dblDeliveredQuantity, Target.dtmDeliveredDate = Source.dtmDeliveredDate, Target.intGenerateLoadId = Source.intGenerateLoadId, Target.intGenerateSequence = Source.intGenerateSequence, Target.strTruckNo = Source.strTruckNo, Target.strTrailerNo1 = Source.strTrailerNo1, Target.strTrailerNo2 = Source.strTrailerNo2, Target.strTrailerNo3 = Source.strTrailerNo3, Target.intUserSecurityId = Source.intUserSecurityId, Target.strExternalLoadNumber = Source.strExternalLoadNumber, Target.intTransportLoadId = Source.intTransportLoadId, Target.intDriverEntityId = Source.intDriverEntityId, Target.ysnDispatched = Source.ysnDispatched, Target.dtmDispatchedDate = Source.dtmDispatchedDate, Target.intDispatcherId = Source.intDispatcherId, Target.ysnDispatchMailSent = Source.ysnDispatchMailSent, Target.dtmDispatchMailSent = Source.dtmDispatchMailSent, Target.dtmCancelDispatchMailSent = Source.dtmCancelDispatchMailSent, Target.intLoadHeaderId = Source.intLoadHeaderId, Target.intSourceType = Source.intSourceType, Target.intPositionId = Source.intPositionId, Target.intWeightUnitMeasureId = Source.intWeightUnitMeasureId, Target.strBLNumber = Source.strBLNumber, Target.dtmBLDate = Source.dtmBLDate, Target.strOriginPort = Source.strOriginPort, Target.strDestinationPort = Source.strDestinationPort, Target.strDestinationCity = Source.strDestinationCity, Target.intTerminalEntityId = Source.intTerminalEntityId, Target.intShippingLineEntityId = Source.intShippingLineEntityId, Target.strServiceContractNumber = Source.strServiceContractNumber, Target.strPackingDescription = Source.strPackingDescription, Target.strMVessel = Source.strMVessel, Target.strMVoyageNumber = Source.strMVoyageNumber, Target.strFVessel = Source.strFVessel, Target.strFVoyageNumber = Source.strFVoyageNumber, Target.intForwardingAgentEntityId = Source.intForwardingAgentEntityId, Target.strForwardingAgentRef = Source.strForwardingAgentRef, Target.intInsurerEntityId = Source.intInsurerEntityId, Target.dblInsuranceValue = Source.dblInsuranceValue, Target.intInsuranceCurrencyId = Source.intInsuranceCurrencyId, Target.dtmDocsToBroker = Source.dtmDocsToBroker, Target.strMarks = Source.strMarks, Target.strMarkingInstructions = Source.strMarkingInstructions, Target.strShippingMode = Source.strShippingMode, Target.intNumberOfContainers = Source.intNumberOfContainers, Target.intContainerTypeId = Source.intContainerTypeId, Target.intBLDraftToBeSentId = Source.intBLDraftToBeSentId, Target.strBLDraftToBeSentType = Source.strBLDraftToBeSentType, Target.strDocPresentationType = Source.strDocPresentationType, Target.intDocPresentationId = Source.intDocPresentationId, Target.dtmDocsReceivedDate = Source.dtmDocsReceivedDate, Target.dtmETAPOL = Source.dtmETAPOL, Target.dtmETSPOL = Source.dtmETSPOL, Target.dtmETAPOD = Source.dtmETAPOD, Target.dtmDeadlineCargo = Source.dtmDeadlineCargo, Target.dtmDeadlineBL = Source.dtmDeadlineBL, Target.dtmISFReceivedDate = Source.dtmISFReceivedDate, Target.dtmISFFiledDate = Source.dtmISFFiledDate, Target.dblDemurrage = Source.dblDemurrage, Target.intDemurrageCurrencyId = Source.intDemurrageCurrencyId, Target.dblDespatch = Source.dblDespatch, Target.intDespatchCurrencyId = Source.intDespatchCurrencyId, Target.dblLoadingRate = Source.dblLoadingRate, Target.intLoadingUnitMeasureId = Source.intLoadingUnitMeasureId, Target.strLoadingPerUnit = Source.strLoadingPerUnit, Target.dblDischargeRate = Source.dblDischargeRate, Target.intDischargeUnitMeasureId = Source.intDischargeUnitMeasureId, Target.strDischargePerUnit = Source.strDischargePerUnit, Target.intTransportationMode = Source.intTransportationMode, Target.intShipmentStatus = Source.intShipmentStatus, Target.ysnPosted = Source.ysnPosted, Target.dtmPostedDate = Source.dtmPostedDate, Target.intTransUsedBy = Source.intTransUsedBy
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intLoadId, intConcurrencyId, strLoadNumber, intCompanyLocationId, intPurchaseSale, intItemId, dblQuantity, intUnitMeasureId, dtmScheduledDate, strCustomerReference, intEquipmentTypeId, intEntityId, intEntityLocationId, intContractDetailId, strComments, intHaulerEntityId, intTicketId, ysnInProgress, dblDeliveredQuantity, dtmDeliveredDate, intGenerateLoadId, intGenerateSequence, strTruckNo, strTrailerNo1, strTrailerNo2, strTrailerNo3, intUserSecurityId, strExternalLoadNumber, intTransportLoadId, intDriverEntityId, ysnDispatched, dtmDispatchedDate, intDispatcherId, ysnDispatchMailSent, dtmDispatchMailSent, dtmCancelDispatchMailSent, intLoadHeaderId, intSourceType, intPositionId, intWeightUnitMeasureId, strBLNumber, dtmBLDate, strOriginPort, strDestinationPort, strDestinationCity, intTerminalEntityId, intShippingLineEntityId, strServiceContractNumber, strPackingDescription, strMVessel, strMVoyageNumber, strFVessel, strFVoyageNumber, intForwardingAgentEntityId, strForwardingAgentRef, intInsurerEntityId, dblInsuranceValue, intInsuranceCurrencyId, dtmDocsToBroker, strMarks, strMarkingInstructions, strShippingMode, intNumberOfContainers, intContainerTypeId, intBLDraftToBeSentId, strBLDraftToBeSentType, strDocPresentationType, intDocPresentationId, dtmDocsReceivedDate, dtmETAPOL, dtmETSPOL, dtmETAPOD, dtmDeadlineCargo, dtmDeadlineBL, dtmISFReceivedDate, dtmISFFiledDate, dblDemurrage, intDemurrageCurrencyId, dblDespatch, intDespatchCurrencyId, dblLoadingRate, intLoadingUnitMeasureId, strLoadingPerUnit, dblDischargeRate, intDischargeUnitMeasureId, strDischargePerUnit, intTransportationMode, intShipmentStatus, ysnPosted, dtmPostedDate, intTransUsedBy)
            VALUES (Source.intLoadId, Source.intConcurrencyId, Source.strLoadNumber, Source.intCompanyLocationId, Source.intPurchaseSale, Source.intItemId, Source.dblQuantity, Source.intUnitMeasureId, Source.dtmScheduledDate, Source.strCustomerReference, Source.intEquipmentTypeId, Source.intEntityId, Source.intEntityLocationId, Source.intContractDetailId, Source.strComments, Source.intHaulerEntityId, Source.intTicketId, Source.ysnInProgress, Source.dblDeliveredQuantity, Source.dtmDeliveredDate, Source.intGenerateLoadId, Source.intGenerateSequence, Source.strTruckNo, Source.strTrailerNo1, Source.strTrailerNo2, Source.strTrailerNo3, Source.intUserSecurityId, Source.strExternalLoadNumber, Source.intTransportLoadId, Source.intDriverEntityId, Source.ysnDispatched, Source.dtmDispatchedDate, Source.intDispatcherId, Source.ysnDispatchMailSent, Source.dtmDispatchMailSent, Source.dtmCancelDispatchMailSent, Source.intLoadHeaderId, Source.intSourceType, Source.intPositionId, Source.intWeightUnitMeasureId, Source.strBLNumber, Source.dtmBLDate, Source.strOriginPort, Source.strDestinationPort, Source.strDestinationCity, Source.intTerminalEntityId, Source.intShippingLineEntityId, Source.strServiceContractNumber, Source.strPackingDescription, Source.strMVessel, Source.strMVoyageNumber, Source.strFVessel, Source.strFVoyageNumber, Source.intForwardingAgentEntityId, Source.strForwardingAgentRef, Source.intInsurerEntityId, Source.dblInsuranceValue, Source.intInsuranceCurrencyId, Source.dtmDocsToBroker, Source.strMarks, Source.strMarkingInstructions, Source.strShippingMode, Source.intNumberOfContainers, Source.intContainerTypeId, Source.intBLDraftToBeSentId, Source.strBLDraftToBeSentType, Source.strDocPresentationType, Source.intDocPresentationId, Source.dtmDocsReceivedDate, Source.dtmETAPOL, Source.dtmETSPOL, Source.dtmETAPOD, Source.dtmDeadlineCargo, Source.dtmDeadlineBL, Source.dtmISFReceivedDate, Source.dtmISFFiledDate, Source.dblDemurrage, Source.intDemurrageCurrencyId, Source.dblDespatch, Source.intDespatchCurrencyId, Source.dblLoadingRate, Source.intLoadingUnitMeasureId, Source.strLoadingPerUnit, Source.dblDischargeRate, Source.intDischargeUnitMeasureId, Source.strDischargePerUnit, Source.intTransportationMode, Source.intShipmentStatus, Source.ysnPosted, Source.dtmPostedDate, Source.intTransUsedBy)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblLGLoad ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblLGLoad OFF

    -- tblLGLoadAllocationDetail
    SET @SQLString = N'EXEC(''MERGE tblLGLoadAllocationDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblLGLoadAllocationDetail) AS Source
        ON (Target.intLoadAllocationDetailId = Source.intLoadAllocationDetailId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intGenerateLoadId = Source.intGenerateLoadId, Target.intPLoadId = Source.intPLoadId, Target.intSLoadId = Source.intSLoadId, Target.dblPAllocatedQty = Source.dblPAllocatedQty, Target.dblSAllocatedQty = Source.dblSAllocatedQty, Target.intPUnitMeasureId = Source.intPUnitMeasureId, Target.intSUnitMeasureId = Source.intSUnitMeasureId, Target.dtmAllocatedDate = Source.dtmAllocatedDate, Target.intUserSecurityId = Source.intUserSecurityId, Target.strComments = Source.strComments
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intLoadAllocationDetailId, intConcurrencyId, intGenerateLoadId, intPLoadId, intSLoadId, dblPAllocatedQty, dblSAllocatedQty, intPUnitMeasureId, intSUnitMeasureId, dtmAllocatedDate, intUserSecurityId, strComments)
            VALUES (Source.intLoadAllocationDetailId, Source.intConcurrencyId, Source.intGenerateLoadId, Source.intPLoadId, Source.intSLoadId, Source.dblPAllocatedQty, Source.dblSAllocatedQty, Source.intPUnitMeasureId, Source.intSUnitMeasureId, Source.dtmAllocatedDate, Source.intUserSecurityId, Source.strComments)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblLGLoadAllocationDetail ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblLGLoadAllocationDetail OFF

    -- tblLGLoadCost
    SET @SQLString = N'EXEC(''MERGE tblLGLoadCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblLGLoadCost) AS Source
        ON (Target.intLoadCostId = Source.intLoadCostId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intLoadId = Source.intLoadId, Target.intItemId = Source.intItemId, Target.intVendorId = Source.intVendorId, Target.strCostMethod = Source.strCostMethod, Target.dblRate = Source.dblRate, Target.intItemUOMId = Source.intItemUOMId, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intLoadCostId, intConcurrencyId, intLoadId, intItemId, intVendorId, strCostMethod, dblRate, intItemUOMId, ysnAccrue, ysnMTM, ysnPrice)
            VALUES (Source.intLoadCostId, Source.intConcurrencyId, Source.intLoadId, Source.intItemId, Source.intVendorId, Source.strCostMethod, Source.dblRate, Source.intItemUOMId, Source.ysnAccrue, Source.ysnMTM, Source.ysnPrice)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblLGLoadCost ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblLGLoadCost OFF

    -- tblLGLoadDetail
    SET @SQLString = N'EXEC(''MERGE tblLGLoadDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblLGLoadDetail) AS Source
        ON (Target.intLoadDetailId = Source.intLoadDetailId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intLoadId = Source.intLoadId, Target.intVendorEntityId = Source.intVendorEntityId, Target.intVendorEntityLocationId = Source.intVendorEntityLocationId, Target.intCustomerEntityId = Source.intCustomerEntityId, Target.intCustomerEntityLocationId = Source.intCustomerEntityLocationId, Target.intItemId = Source.intItemId, Target.intPContractDetailId = Source.intPContractDetailId, Target.intSContractDetailId = Source.intSContractDetailId, Target.intPCompanyLocationId = Source.intPCompanyLocationId, Target.intSCompanyLocationId = Source.intSCompanyLocationId, Target.dblQuantity = Source.dblQuantity, Target.intItemUOMId = Source.intItemUOMId, Target.dblGross = Source.dblGross, Target.dblTare = Source.dblTare, Target.dblNet = Source.dblNet, Target.intWeightItemUOMId = Source.intWeightItemUOMId, Target.dblDeliveredQuantity = Source.dblDeliveredQuantity, Target.dblDeliveredGross = Source.dblDeliveredGross, Target.dblDeliveredTare = Source.dblDeliveredTare, Target.dblDeliveredNet = Source.dblDeliveredNet, Target.strLotAlias = Source.strLotAlias, Target.strSupplierLotNumber = Source.strSupplierLotNumber, Target.dtmProductionDate = Source.dtmProductionDate, Target.strScheduleInfoMsg = Source.strScheduleInfoMsg, Target.ysnUpdateScheduleInfo = Source.ysnUpdateScheduleInfo, Target.ysnPrintScheduleInfo = Source.ysnPrintScheduleInfo, Target.strLoadDirectionMsg = Source.strLoadDirectionMsg, Target.ysnUpdateLoadDirections = Source.ysnUpdateLoadDirections, Target.ysnPrintLoadDirections = Source.ysnPrintLoadDirections, Target.strVendorReference = Source.strVendorReference, Target.strCustomerReference = Source.strCustomerReference, Target.intAllocationDetailId = Source.intAllocationDetailId, Target.intPickLotDetailId = Source.intPickLotDetailId, Target.intPSubLocationId = Source.intPSubLocationId, Target.intSSubLocationId = Source.intSSubLocationId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intLoadDetailId, intConcurrencyId, intLoadId, intVendorEntityId, intVendorEntityLocationId, intCustomerEntityId, intCustomerEntityLocationId, intItemId, intPContractDetailId, intSContractDetailId, intPCompanyLocationId, intSCompanyLocationId, dblQuantity, intItemUOMId, dblGross, dblTare, dblNet, intWeightItemUOMId, dblDeliveredQuantity, dblDeliveredGross, dblDeliveredTare, dblDeliveredNet, strLotAlias, strSupplierLotNumber, dtmProductionDate, strScheduleInfoMsg, ysnUpdateScheduleInfo, ysnPrintScheduleInfo, strLoadDirectionMsg, ysnUpdateLoadDirections, ysnPrintLoadDirections, strVendorReference, strCustomerReference, intAllocationDetailId, intPickLotDetailId, intPSubLocationId, intSSubLocationId)
            VALUES (Source.intLoadDetailId, Source.intConcurrencyId, Source.intLoadId, Source.intVendorEntityId, Source.intVendorEntityLocationId, Source.intCustomerEntityId, Source.intCustomerEntityLocationId, Source.intItemId, Source.intPContractDetailId, Source.intSContractDetailId, Source.intPCompanyLocationId, Source.intSCompanyLocationId, Source.dblQuantity, Source.intItemUOMId, Source.dblGross, Source.dblTare, Source.dblNet, Source.intWeightItemUOMId, Source.dblDeliveredQuantity, Source.dblDeliveredGross, Source.dblDeliveredTare, Source.dblDeliveredNet, Source.strLotAlias, Source.strSupplierLotNumber, Source.dtmProductionDate, Source.strScheduleInfoMsg, Source.ysnUpdateScheduleInfo, Source.ysnPrintScheduleInfo, Source.strLoadDirectionMsg, Source.ysnUpdateLoadDirections, Source.ysnPrintLoadDirections, Source.strVendorReference, Source.strCustomerReference, Source.intAllocationDetailId, Source.intPickLotDetailId, Source.intPSubLocationId, Source.intSSubLocationId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblLGLoadDetail ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblLGLoadDetail OFF

    -- tblICItem
    SET @SQLString = N'EXEC(''MERGE tblICItem AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICItem) AS Source
        ON (Target.intItemId = Source.intItemId)
        WHEN MATCHED THEN
            UPDATE SET Target.strItemNo = Source.strItemNo, Target.strShortName = Source.strShortName, Target.strType = Source.strType, Target.strDescription = Source.strDescription, Target.intManufacturerId = Source.intManufacturerId, Target.intBrandId = Source.intBrandId, Target.intCategoryId = Source.intCategoryId, Target.strStatus = Source.strStatus, Target.strModelNo = Source.strModelNo, Target.strInventoryTracking = Source.strInventoryTracking, Target.strLotTracking = Source.strLotTracking, Target.ysnRequireCustomerApproval = Source.ysnRequireCustomerApproval, Target.intRecipeId = Source.intRecipeId, Target.ysnSanitationRequired = Source.ysnSanitationRequired, Target.intLifeTime = Source.intLifeTime, Target.strLifeTimeType = Source.strLifeTimeType, Target.intReceiveLife = Source.intReceiveLife, Target.strGTIN = Source.strGTIN, Target.strRotationType = Source.strRotationType, Target.intNMFCId = Source.intNMFCId, Target.ysnStrictFIFO = Source.ysnStrictFIFO, Target.intDimensionUOMId = Source.intDimensionUOMId, Target.dblHeight = Source.dblHeight, Target.dblWidth = Source.dblWidth, Target.dblDepth = Source.dblDepth, Target.intWeightUOMId = Source.intWeightUOMId, Target.dblWeight = Source.dblWeight, Target.intMaterialPackTypeId = Source.intMaterialPackTypeId, Target.strMaterialSizeCode = Source.strMaterialSizeCode, Target.intInnerUnits = Source.intInnerUnits, Target.intLayerPerPallet = Source.intLayerPerPallet, Target.intUnitPerLayer = Source.intUnitPerLayer, Target.dblStandardPalletRatio = Source.dblStandardPalletRatio, Target.strMask1 = Source.strMask1, Target.strMask2 = Source.strMask2, Target.strMask3 = Source.strMask3, Target.dblMaxWeightPerPack = Source.dblMaxWeightPerPack, Target.intPatronageCategoryId = Source.intPatronageCategoryId, Target.intPatronageCategoryDirectId = Source.intPatronageCategoryDirectId, Target.ysnStockedItem = Source.ysnStockedItem, Target.ysnDyedFuel = Source.ysnDyedFuel, Target.strBarcodePrint = Source.strBarcodePrint, Target.ysnMSDSRequired = Source.ysnMSDSRequired, Target.strEPANumber = Source.strEPANumber, Target.ysnInboundTax = Source.ysnInboundTax, Target.ysnOutboundTax = Source.ysnOutboundTax, Target.ysnRestrictedChemical = Source.ysnRestrictedChemical, Target.ysnFuelItem = Source.ysnFuelItem, Target.ysnTankRequired = Source.ysnTankRequired, Target.ysnAvailableTM = Source.ysnAvailableTM, Target.dblDefaultFull = Source.dblDefaultFull, Target.strFuelInspectFee = Source.strFuelInspectFee, Target.strRINRequired = Source.strRINRequired, Target.intRINFuelTypeId = Source.intRINFuelTypeId, Target.dblDenaturantPercent = Source.dblDenaturantPercent, Target.ysnTonnageTax = Source.ysnTonnageTax, Target.ysnLoadTracking = Source.ysnLoadTracking, Target.dblMixOrder = Source.dblMixOrder, Target.ysnHandAddIngredient = Source.ysnHandAddIngredient, Target.intMedicationTag = Source.intMedicationTag, Target.intIngredientTag = Source.intIngredientTag, Target.strVolumeRebateGroup = Source.strVolumeRebateGroup, Target.intPhysicalItem = Source.intPhysicalItem, Target.ysnExtendPickTicket = Source.ysnExtendPickTicket, Target.ysnExportEDI = Source.ysnExportEDI, Target.ysnHazardMaterial = Source.ysnHazardMaterial, Target.ysnMaterialFee = Source.ysnMaterialFee, Target.ysnAutoBlend = Source.ysnAutoBlend, Target.dblUserGroupFee = Source.dblUserGroupFee, Target.dblWeightTolerance = Source.dblWeightTolerance, Target.dblOverReceiveTolerance = Source.dblOverReceiveTolerance, Target.strMaintenanceCalculationMethod = Source.strMaintenanceCalculationMethod, Target.dblMaintenanceRate = Source.dblMaintenanceRate, Target.ysnListBundleSeparately = Source.ysnListBundleSeparately, Target.intModuleId = Source.intModuleId, Target.strNACSCategory = Source.strNACSCategory, Target.strWICCode = Source.strWICCode, Target.intAGCategory = Source.intAGCategory, Target.ysnReceiptCommentRequired = Source.ysnReceiptCommentRequired, Target.strCountCode = Source.strCountCode, Target.ysnLandedCost = Source.ysnLandedCost, Target.strLeadTime = Source.strLeadTime, Target.ysnTaxable = Source.ysnTaxable, Target.strKeywords = Source.strKeywords, Target.dblCaseQty = Source.dblCaseQty, Target.dtmDateShip = Source.dtmDateShip, Target.dblTaxExempt = Source.dblTaxExempt, Target.ysnDropShip = Source.ysnDropShip, Target.ysnCommisionable = Source.ysnCommisionable, Target.ysnSpecialCommission = Source.ysnSpecialCommission, Target.intCommodityId = Source.intCommodityId, Target.intCommodityHierarchyId = Source.intCommodityHierarchyId, Target.dblGAShrinkFactor = Source.dblGAShrinkFactor, Target.intOriginId = Source.intOriginId, Target.intProductTypeId = Source.intProductTypeId, Target.intRegionId = Source.intRegionId, Target.intSeasonId = Source.intSeasonId, Target.intClassVarietyId = Source.intClassVarietyId, Target.intProductLineId = Source.intProductLineId, Target.intGradeId = Source.intGradeId, Target.strMarketValuation = Source.strMarketValuation, Target.ysnInventoryCost = Source.ysnInventoryCost, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice, Target.strCostMethod = Source.strCostMethod, Target.strCostType = Source.strCostType, Target.intOnCostTypeId = Source.intOnCostTypeId, Target.dblAmount = Source.dblAmount, Target.intCostUOMId = Source.intCostUOMId, Target.intPackTypeId = Source.intPackTypeId, Target.strWeightControlCode = Source.strWeightControlCode, Target.dblBlendWeight = Source.dblBlendWeight, Target.dblNetWeight = Source.dblNetWeight, Target.dblUnitPerCase = Source.dblUnitPerCase, Target.dblQuarantineDuration = Source.dblQuarantineDuration, Target.intOwnerId = Source.intOwnerId, Target.intCustomerId = Source.intCustomerId, Target.dblCaseWeight = Source.dblCaseWeight, Target.strWarehouseStatus = Source.strWarehouseStatus, Target.ysnKosherCertified = Source.ysnKosherCertified, Target.ysnFairTradeCompliant = Source.ysnFairTradeCompliant, Target.ysnOrganic = Source.ysnOrganic, Target.ysnRainForestCertified = Source.ysnRainForestCertified, Target.dblRiskScore = Source.dblRiskScore, Target.dblDensity = Source.dblDensity, Target.dtmDateAvailable = Source.dtmDateAvailable, Target.ysnMinorIngredient = Source.ysnMinorIngredient, Target.ysnExternalItem = Source.ysnExternalItem, Target.strExternalGroup = Source.strExternalGroup, Target.ysnSellableItem = Source.ysnSellableItem, Target.dblMinStockWeeks = Source.dblMinStockWeeks, Target.dblFullContainerSize = Source.dblFullContainerSize, Target.ysnHasMFTImplication = Source.ysnHasMFTImplication, Target.intBuyingGroupId = Source.intBuyingGroupId, Target.intAccountManagerId = Source.intAccountManagerId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intItemId, strItemNo, strShortName, strType, strDescription, intManufacturerId, intBrandId, intCategoryId, strStatus, strModelNo, strInventoryTracking, strLotTracking, ysnRequireCustomerApproval, intRecipeId, ysnSanitationRequired, intLifeTime, strLifeTimeType, intReceiveLife, strGTIN, strRotationType, intNMFCId, ysnStrictFIFO, intDimensionUOMId, dblHeight, dblWidth, dblDepth, intWeightUOMId, dblWeight, intMaterialPackTypeId, strMaterialSizeCode, intInnerUnits, intLayerPerPallet, intUnitPerLayer, dblStandardPalletRatio, strMask1, strMask2, strMask3, dblMaxWeightPerPack, intPatronageCategoryId, intPatronageCategoryDirectId, ysnStockedItem, ysnDyedFuel, strBarcodePrint, ysnMSDSRequired, strEPANumber, ysnInboundTax, ysnOutboundTax, ysnRestrictedChemical, ysnFuelItem, ysnTankRequired, ysnAvailableTM, dblDefaultFull, strFuelInspectFee, strRINRequired, intRINFuelTypeId, dblDenaturantPercent, ysnTonnageTax, ysnLoadTracking, dblMixOrder, ysnHandAddIngredient, intMedicationTag, intIngredientTag, strVolumeRebateGroup, intPhysicalItem, ysnExtendPickTicket, ysnExportEDI, ysnHazardMaterial, ysnMaterialFee, ysnAutoBlend, dblUserGroupFee, dblWeightTolerance, dblOverReceiveTolerance, strMaintenanceCalculationMethod, dblMaintenanceRate, ysnListBundleSeparately, intModuleId, strNACSCategory, strWICCode, intAGCategory, ysnReceiptCommentRequired, strCountCode, ysnLandedCost, strLeadTime, ysnTaxable, strKeywords, dblCaseQty, dtmDateShip, dblTaxExempt, ysnDropShip, ysnCommisionable, ysnSpecialCommission, intCommodityId, intCommodityHierarchyId, dblGAShrinkFactor, intOriginId, intProductTypeId, intRegionId, intSeasonId, intClassVarietyId, intProductLineId, intGradeId, strMarketValuation, ysnInventoryCost, ysnAccrue, ysnMTM, ysnPrice, strCostMethod, strCostType, intOnCostTypeId, dblAmount, intCostUOMId, intPackTypeId, strWeightControlCode, dblBlendWeight, dblNetWeight, dblUnitPerCase, dblQuarantineDuration, intOwnerId, intCustomerId, dblCaseWeight, strWarehouseStatus, ysnKosherCertified, ysnFairTradeCompliant, ysnOrganic, ysnRainForestCertified, dblRiskScore, dblDensity, dtmDateAvailable, ysnMinorIngredient, ysnExternalItem, strExternalGroup, ysnSellableItem, dblMinStockWeeks, dblFullContainerSize, ysnHasMFTImplication, intBuyingGroupId, intAccountManagerId, intConcurrencyId)
            VALUES (Source.intItemId, Source.strItemNo, Source.strShortName, Source.strType, Source.strDescription, Source.intManufacturerId, Source.intBrandId, Source.intCategoryId, Source.strStatus, Source.strModelNo, Source.strInventoryTracking, Source.strLotTracking, Source.ysnRequireCustomerApproval, Source.intRecipeId, Source.ysnSanitationRequired, Source.intLifeTime, Source.strLifeTimeType, Source.intReceiveLife, Source.strGTIN, Source.strRotationType, Source.intNMFCId, Source.ysnStrictFIFO, Source.intDimensionUOMId, Source.dblHeight, Source.dblWidth, Source.dblDepth, Source.intWeightUOMId, Source.dblWeight, Source.intMaterialPackTypeId, Source.strMaterialSizeCode, Source.intInnerUnits, Source.intLayerPerPallet, Source.intUnitPerLayer, Source.dblStandardPalletRatio, Source.strMask1, Source.strMask2, Source.strMask3, Source.dblMaxWeightPerPack, Source.intPatronageCategoryId, Source.intPatronageCategoryDirectId, Source.ysnStockedItem, Source.ysnDyedFuel, Source.strBarcodePrint, Source.ysnMSDSRequired, Source.strEPANumber, Source.ysnInboundTax, Source.ysnOutboundTax, Source.ysnRestrictedChemical, Source.ysnFuelItem, Source.ysnTankRequired, Source.ysnAvailableTM, Source.dblDefaultFull, Source.strFuelInspectFee, Source.strRINRequired, Source.intRINFuelTypeId, Source.dblDenaturantPercent, Source.ysnTonnageTax, Source.ysnLoadTracking, Source.dblMixOrder, Source.ysnHandAddIngredient, Source.intMedicationTag, Source.intIngredientTag, Source.strVolumeRebateGroup, Source.intPhysicalItem, Source.ysnExtendPickTicket, Source.ysnExportEDI, Source.ysnHazardMaterial, Source.ysnMaterialFee, Source.ysnAutoBlend, Source.dblUserGroupFee, Source.dblWeightTolerance, Source.dblOverReceiveTolerance, Source.strMaintenanceCalculationMethod, Source.dblMaintenanceRate, Source.ysnListBundleSeparately, Source.intModuleId, Source.strNACSCategory, Source.strWICCode, Source.intAGCategory, Source.ysnReceiptCommentRequired, Source.strCountCode, Source.ysnLandedCost, Source.strLeadTime, Source.ysnTaxable, Source.strKeywords, Source.dblCaseQty, Source.dtmDateShip, Source.dblTaxExempt, Source.ysnDropShip, Source.ysnCommisionable, Source.ysnSpecialCommission, Source.intCommodityId, Source.intCommodityHierarchyId, Source.dblGAShrinkFactor, Source.intOriginId, Source.intProductTypeId, Source.intRegionId, Source.intSeasonId, Source.intClassVarietyId, Source.intProductLineId, Source.intGradeId, Source.strMarketValuation, Source.ysnInventoryCost, Source.ysnAccrue, Source.ysnMTM, Source.ysnPrice, Source.strCostMethod, Source.strCostType, Source.intOnCostTypeId, Source.dblAmount, Source.intCostUOMId, Source.intPackTypeId, Source.strWeightControlCode, Source.dblBlendWeight, Source.dblNetWeight, Source.dblUnitPerCase, Source.dblQuarantineDuration, Source.intOwnerId, Source.intCustomerId, Source.dblCaseWeight, Source.strWarehouseStatus, Source.ysnKosherCertified, Source.ysnFairTradeCompliant, Source.ysnOrganic, Source.ysnRainForestCertified, Source.dblRiskScore, Source.dblDensity, Source.dtmDateAvailable, Source.ysnMinorIngredient, Source.ysnExternalItem, Source.strExternalGroup, Source.ysnSellableItem, Source.dblMinStockWeeks, Source.dblFullContainerSize, Source.ysnHasMFTImplication, Source.intBuyingGroupId, Source.intAccountManagerId, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICItem ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICItem OFF

    -- tblICCommodity
    SET @SQLString = N'EXEC(''MERGE tblICCommodity AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICCommodity) AS Source
        ON (Target.intCommodityId = Source.intCommodityId)
        WHEN MATCHED THEN
            UPDATE SET Target.strCommodityCode = Source.strCommodityCode, Target.strDescription = Source.strDescription, Target.ysnExchangeTraded = Source.ysnExchangeTraded, Target.intFutureMarketId = Source.intFutureMarketId, Target.intDecimalDPR = Source.intDecimalDPR, Target.dblConsolidateFactor = Source.dblConsolidateFactor, Target.ysnFXExposure = Source.ysnFXExposure, Target.dblPriceCheckMin = Source.dblPriceCheckMin, Target.dblPriceCheckMax = Source.dblPriceCheckMax, Target.strCheckoffTaxDesc = Source.strCheckoffTaxDesc, Target.strCheckoffAllState = Source.strCheckoffAllState, Target.strInsuranceTaxDesc = Source.strInsuranceTaxDesc, Target.strInsuranceAllState = Source.strInsuranceAllState, Target.dtmCropEndDateCurrent = Source.dtmCropEndDateCurrent, Target.dtmCropEndDateNew = Source.dtmCropEndDateNew, Target.strEDICode = Source.strEDICode, Target.intScheduleStoreId = Source.intScheduleStoreId, Target.intScheduleDiscountId = Source.intScheduleDiscountId, Target.intScaleAutoDistId = Source.intScaleAutoDistId, Target.ysnAllowLoadContracts = Source.ysnAllowLoadContracts, Target.dblMaxUnder = Source.dblMaxUnder, Target.dblMaxOver = Source.dblMaxOver, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intCommodityId, strCommodityCode, strDescription, ysnExchangeTraded, intFutureMarketId, intDecimalDPR, dblConsolidateFactor, ysnFXExposure, dblPriceCheckMin, dblPriceCheckMax, strCheckoffTaxDesc, strCheckoffAllState, strInsuranceTaxDesc, strInsuranceAllState, dtmCropEndDateCurrent, dtmCropEndDateNew, strEDICode, intScheduleStoreId, intScheduleDiscountId, intScaleAutoDistId, ysnAllowLoadContracts, dblMaxUnder, dblMaxOver, intConcurrencyId)
            VALUES (Source.intCommodityId, Source.strCommodityCode, Source.strDescription, Source.ysnExchangeTraded, Source.intFutureMarketId, Source.intDecimalDPR, Source.dblConsolidateFactor, Source.ysnFXExposure, Source.dblPriceCheckMin, Source.dblPriceCheckMax, Source.strCheckoffTaxDesc, Source.strCheckoffAllState, Source.strInsuranceTaxDesc, Source.strInsuranceAllState, Source.dtmCropEndDateCurrent, Source.dtmCropEndDateNew, Source.strEDICode, Source.intScheduleStoreId, Source.intScheduleDiscountId, Source.intScaleAutoDistId, Source.ysnAllowLoadContracts, Source.dblMaxUnder, Source.dblMaxOver, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICCommodity ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICCommodity OFF

    -- tblICCommodityAccount
    SET @SQLString = N'EXEC(''MERGE tblICCommodityAccount AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICCommodityAccount) AS Source
        ON (Target.intCommodityAccountId = Source.intCommodityAccountId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCommodityId = Source.intCommodityId, Target.intAccountCategoryId = Source.intAccountCategoryId, Target.intAccountId = Source.intAccountId, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intCommodityAccountId, intCommodityId, intAccountCategoryId, intAccountId, intSort, intConcurrencyId)
            VALUES (Source.intCommodityAccountId, Source.intCommodityId, Source.intAccountCategoryId, Source.intAccountId, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICCommodityAccount ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICCommodityAccount OFF

    -- tblICCommodityAttribute
    SET @SQLString = N'EXEC(''MERGE tblICCommodityAttribute AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICCommodityAttribute) AS Source
        ON (Target.intCommodityAttributeId = Source.intCommodityAttributeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCommodityId = Source.intCommodityId, Target.strType = Source.strType, Target.strDescription = Source.strDescription, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intCommodityAttributeId, intCommodityId, strType, strDescription, intSort, intConcurrencyId)
            VALUES (Source.intCommodityAttributeId, Source.intCommodityId, Source.strType, Source.strDescription, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICCommodityAttribute ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICCommodityAttribute OFF

    -- tblICCommodityGroup
    SET @SQLString = N'EXEC(''MERGE tblICCommodityGroup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICCommodityGroup) AS Source
        ON (Target.intCommodityGroupId = Source.intCommodityGroupId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCommodityId = Source.intCommodityId, Target.intParentGroupId = Source.intParentGroupId, Target.strDescription = Source.strDescription, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intCommodityGroupId, intCommodityId, intParentGroupId, strDescription, intSort, intConcurrencyId)
            VALUES (Source.intCommodityGroupId, Source.intCommodityId, Source.intParentGroupId, Source.strDescription, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICCommodityGroup ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICCommodityGroup OFF

    -- tblICCommodityProductLine
    SET @SQLString = N'EXEC(''MERGE tblICCommodityProductLine AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICCommodityProductLine) AS Source
        ON (Target.intCommodityProductLineId = Source.intCommodityProductLineId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCommodityId = Source.intCommodityId, Target.strDescription = Source.strDescription, Target.ysnDeltaHedge = Source.ysnDeltaHedge, Target.dblDeltaPercent = Source.dblDeltaPercent, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intCommodityProductLineId, intCommodityId, strDescription, ysnDeltaHedge, dblDeltaPercent, intSort, intConcurrencyId)
            VALUES (Source.intCommodityProductLineId, Source.intCommodityId, Source.strDescription, Source.ysnDeltaHedge, Source.dblDeltaPercent, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICCommodityProductLine ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICCommodityProductLine OFF

    -- tblICCommodityUnitMeasure
    SET @SQLString = N'EXEC(''MERGE tblICCommodityUnitMeasure AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICCommodityUnitMeasure) AS Source
        ON (Target.intCommodityUnitMeasureId = Source.intCommodityUnitMeasureId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCommodityId = Source.intCommodityId, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.dblUnitQty = Source.dblUnitQty, Target.ysnStockUnit = Source.ysnStockUnit, Target.ysnDefault = Source.ysnDefault, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intCommodityUnitMeasureId, intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intSort, intConcurrencyId)
            VALUES (Source.intCommodityUnitMeasureId, Source.intCommodityId, Source.intUnitMeasureId, Source.dblUnitQty, Source.ysnStockUnit, Source.ysnDefault, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICCommodityUnitMeasure ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICCommodityUnitMeasure OFF

    -- tblICStorageLocation
    SET @SQLString = N'EXEC(''MERGE tblICStorageLocation AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICStorageLocation) AS Source
        ON (Target.intStorageLocationId = Source.intStorageLocationId)
        WHEN MATCHED THEN
            UPDATE SET Target.strName = Source.strName, Target.strDescription = Source.strDescription, Target.intStorageUnitTypeId = Source.intStorageUnitTypeId, Target.intLocationId = Source.intLocationId, Target.intSubLocationId = Source.intSubLocationId, Target.intParentStorageLocationId = Source.intParentStorageLocationId, Target.ysnAllowConsume = Source.ysnAllowConsume, Target.ysnAllowMultipleItem = Source.ysnAllowMultipleItem, Target.ysnAllowMultipleLot = Source.ysnAllowMultipleLot, Target.ysnMergeOnMove = Source.ysnMergeOnMove, Target.ysnCycleCounted = Source.ysnCycleCounted, Target.ysnDefaultWHStagingUnit = Source.ysnDefaultWHStagingUnit, Target.intRestrictionId = Source.intRestrictionId, Target.strUnitGroup = Source.strUnitGroup, Target.dblMinBatchSize = Source.dblMinBatchSize, Target.dblBatchSize = Source.dblBatchSize, Target.intBatchSizeUOMId = Source.intBatchSizeUOMId, Target.intSequence = Source.intSequence, Target.ysnActive = Source.ysnActive, Target.intRelativeX = Source.intRelativeX, Target.intRelativeY = Source.intRelativeY, Target.intRelativeZ = Source.intRelativeZ, Target.intCommodityId = Source.intCommodityId, Target.dblPackFactor = Source.dblPackFactor, Target.dblEffectiveDepth = Source.dblEffectiveDepth, Target.dblUnitPerFoot = Source.dblUnitPerFoot, Target.dblResidualUnit = Source.dblResidualUnit, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageLocationId, strName, strDescription, intStorageUnitTypeId, intLocationId, intSubLocationId, intParentStorageLocationId, ysnAllowConsume, ysnAllowMultipleItem, ysnAllowMultipleLot, ysnMergeOnMove, ysnCycleCounted, ysnDefaultWHStagingUnit, intRestrictionId, strUnitGroup, dblMinBatchSize, dblBatchSize, intBatchSizeUOMId, intSequence, ysnActive, intRelativeX, intRelativeY, intRelativeZ, intCommodityId, dblPackFactor, dblEffectiveDepth, dblUnitPerFoot, dblResidualUnit, intConcurrencyId)
            VALUES (Source.intStorageLocationId, Source.strName, Source.strDescription, Source.intStorageUnitTypeId, Source.intLocationId, Source.intSubLocationId, Source.intParentStorageLocationId, Source.ysnAllowConsume, Source.ysnAllowMultipleItem, Source.ysnAllowMultipleLot, Source.ysnMergeOnMove, Source.ysnCycleCounted, Source.ysnDefaultWHStagingUnit, Source.intRestrictionId, Source.strUnitGroup, Source.dblMinBatchSize, Source.dblBatchSize, Source.intBatchSizeUOMId, Source.intSequence, Source.ysnActive, Source.intRelativeX, Source.intRelativeY, Source.intRelativeZ, Source.intCommodityId, Source.dblPackFactor, Source.dblEffectiveDepth, Source.dblUnitPerFoot, Source.dblResidualUnit, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICStorageLocation ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICStorageLocation OFF

    -- tblICStorageLocationCategory
    SET @SQLString = N'EXEC(''MERGE tblICStorageLocationCategory AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICStorageLocationCategory) AS Source
        ON (Target.intStorageLocationCategoryId = Source.intStorageLocationCategoryId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageLocationId = Source.intStorageLocationId, Target.intCategoryId = Source.intCategoryId, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageLocationCategoryId, intStorageLocationId, intCategoryId, intSort, intConcurrencyId)
            VALUES (Source.intStorageLocationCategoryId, Source.intStorageLocationId, Source.intCategoryId, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICStorageLocationCategory ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICStorageLocationCategory OFF

    -- tblICStorageLocationContainer
    SET @SQLString = N'EXEC(''MERGE tblICStorageLocationContainer AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICStorageLocationContainer) AS Source
        ON (Target.intStorageLocationContainerId = Source.intStorageLocationContainerId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageLocationId = Source.intStorageLocationId, Target.intContainerId = Source.intContainerId, Target.intExternalSystemId = Source.intExternalSystemId, Target.intContainerTypeId = Source.intContainerTypeId, Target.strLastUpdatedBy = Source.strLastUpdatedBy, Target.dtmLastUpdatedOn = Source.dtmLastUpdatedOn, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageLocationContainerId, intStorageLocationId, intContainerId, intExternalSystemId, intContainerTypeId, strLastUpdatedBy, dtmLastUpdatedOn, intSort, intConcurrencyId)
            VALUES (Source.intStorageLocationContainerId, Source.intStorageLocationId, Source.intContainerId, Source.intExternalSystemId, Source.intContainerTypeId, Source.strLastUpdatedBy, Source.dtmLastUpdatedOn, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICStorageLocationContainer ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICStorageLocationContainer OFF

    -- tblICStorageLocationMeasurement
    SET @SQLString = N'EXEC(''MERGE tblICStorageLocationMeasurement AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICStorageLocationMeasurement) AS Source
        ON (Target.intStorageLocationMeasurementId = Source.intStorageLocationMeasurementId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageLocationId = Source.intStorageLocationId, Target.intMeasurementId = Source.intMeasurementId, Target.intReadingPointId = Source.intReadingPointId, Target.ysnActive = Source.ysnActive, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageLocationMeasurementId, intStorageLocationId, intMeasurementId, intReadingPointId, ysnActive, intSort, intConcurrencyId)
            VALUES (Source.intStorageLocationMeasurementId, Source.intStorageLocationId, Source.intMeasurementId, Source.intReadingPointId, Source.ysnActive, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICStorageLocationMeasurement ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICStorageLocationMeasurement OFF

    -- tblICStorageLocationSku
    SET @SQLString = N'EXEC(''MERGE tblICStorageLocationSku AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblICStorageLocationSku) AS Source
        ON (Target.intStorageLocationSkuId = Source.intStorageLocationSkuId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageLocationId = Source.intStorageLocationId, Target.intItemId = Source.intItemId, Target.intSkuId = Source.intSkuId, Target.dblQuantity = Source.dblQuantity, Target.intContainerId = Source.intContainerId, Target.intLotCodeId = Source.intLotCodeId, Target.intLotStatusId = Source.intLotStatusId, Target.intOwnerId = Source.intOwnerId, Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intStorageLocationSkuId, intStorageLocationId, intItemId, intSkuId, dblQuantity, intContainerId, intLotCodeId, intLotStatusId, intOwnerId, intSort, intConcurrencyId)
            VALUES (Source.intStorageLocationSkuId, Source.intStorageLocationId, Source.intItemId, Source.intSkuId, Source.dblQuantity, Source.intContainerId, Source.intLotCodeId, Source.intLotStatusId, Source.intOwnerId, Source.intSort, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblICStorageLocationSku ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblICStorageLocationSku OFF

    -- tblQMTicketDiscount
    SET @SQLString = N'EXEC(''MERGE tblQMTicketDiscount AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblQMTicketDiscount) AS Source
        ON (Target.intTicketDiscountId = Source.intTicketDiscountId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.dblGradeReading = Source.dblGradeReading, Target.strCalcMethod = Source.strCalcMethod, Target.strShrinkWhat = Source.strShrinkWhat, Target.dblShrinkPercent = Source.dblShrinkPercent, Target.dblDiscountAmount = Source.dblDiscountAmount, Target.dblDiscountDue = Source.dblDiscountDue, Target.dblDiscountPaid = Source.dblDiscountPaid, Target.ysnGraderAutoEntry = Source.ysnGraderAutoEntry, Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.dtmDiscountPaidDate = Source.dtmDiscountPaidDate, Target.intTicketId = Source.intTicketId, Target.intTicketFileId = Source.intTicketFileId, Target.strSourceType = Source.strSourceType, Target.intSort = Source.intSort, Target.strDiscountChargeType = Source.strDiscountChargeType
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketDiscountId, intConcurrencyId, dblGradeReading, strCalcMethod, strShrinkWhat, dblShrinkPercent, dblDiscountAmount, dblDiscountDue, dblDiscountPaid, ysnGraderAutoEntry, intDiscountScheduleCodeId, dtmDiscountPaidDate, intTicketId, intTicketFileId, strSourceType, intSort, strDiscountChargeType)
            VALUES (Source.intTicketDiscountId, Source.intConcurrencyId, Source.dblGradeReading, Source.strCalcMethod, Source.strShrinkWhat, Source.dblShrinkPercent, Source.dblDiscountAmount, Source.dblDiscountDue, Source.dblDiscountPaid, Source.ysnGraderAutoEntry, Source.intDiscountScheduleCodeId, Source.dtmDiscountPaidDate, Source.intTicketId, Source.intTicketFileId, Source.strSourceType, Source.intSort, Source.strDiscountChargeType)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblQMTicketDiscount ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblQMTicketDiscount OFF

    -- tblSCScaleSetup
    SET @SQLString = N'MERGE tblSCScaleSetup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.repDB.dbo.tblSCScaleSetup) AS Source
        ON (Target.intScaleSetupId = Source.intScaleSetupId)
        WHEN MATCHED THEN
            UPDATE SET Target.strStationShortDescription = Source.strStationShortDescription, Target.strStationDescription = Source.strStationDescription, Target.intStationType = Source.intStationType, Target.intTicketPoolId = Source.intTicketPoolId, Target.strAddress = Source.strAddress, Target.strZipCode = Source.strZipCode, Target.strCity = Source.strCity, Target.strState = Source.strState, Target.strCountry = Source.strCountry, Target.strPhone = Source.strPhone, Target.intLocationId = Source.intLocationId, Target.ysnAllowManualTicketNumber = Source.ysnAllowManualTicketNumber, Target.strScaleOperator = Source.strScaleOperator, Target.intScaleProcessing = Source.intScaleProcessing, Target.intTransferDelayMinutes = Source.intTransferDelayMinutes, Target.intBatchTransferInterval = Source.intBatchTransferInterval, Target.strLocalFilePath = Source.strLocalFilePath, Target.strServerPath = Source.strServerPath, Target.strWebServicePath = Source.strWebServicePath, Target.intMinimumPurgeDays = Source.intMinimumPurgeDays, Target.dtmLastPurgeDate = Source.dtmLastPurgeDate, Target.intLastPurgeUserId = Source.intLastPurgeUserId, Target.intInScaleDeviceId = Source.intInScaleDeviceId, Target.ysnDisableInScale = Source.ysnDisableInScale, Target.intOutScaleDeviceId = Source.intOutScaleDeviceId, Target.ysnDisableOutScale = Source.ysnDisableOutScale, Target.ysnShowOutScale = Source.ysnShowOutScale, Target.ysnAllowZeroWeights = Source.ysnAllowZeroWeights, Target.strWeightDescription = Source.strWeightDescription, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.intGraderDeviceId = Source.intGraderDeviceId, Target.intAlternateGraderDeviceId = Source.intAlternateGraderDeviceId, Target.intLEDDeviceId = Source.intLEDDeviceId, Target.ysnCustomerFirst = Source.ysnCustomerFirst, Target.intAllowOtherLocationContracts = Source.intAllowOtherLocationContracts, Target.intWeightDisplayDelay = Source.intWeightDisplayDelay, Target.intTicketSelectionDelay = Source.intTicketSelectionDelay, Target.intFreightHaulerIDRequired = Source.intFreightHaulerIDRequired, Target.intBinNumberRequired = Source.intBinNumberRequired, Target.intDriverNameRequired = Source.intDriverNameRequired, Target.intTruckIDRequired = Source.intTruckIDRequired, Target.intTrackAxleCount = Source.intTrackAxleCount, Target.intRequireSpotSalePrice = Source.intRequireSpotSalePrice, Target.ysnTicketCommentRequired = Source.ysnTicketCommentRequired, Target.ysnAllowElectronicSpotPrice = Source.ysnAllowElectronicSpotPrice, Target.ysnRefreshContractsOnOpen = Source.ysnRefreshContractsOnOpen, Target.ysnTrackVariety = Source.ysnTrackVariety, Target.ysnManualGrading = Source.ysnManualGrading, Target.ysnLockStoredGrade = Source.ysnLockStoredGrade, Target.ysnAllowManualWeight = Source.ysnAllowManualWeight, Target.intStorePitInformation = Source.intStorePitInformation, Target.ysnReferenceNumberRequired = Source.ysnReferenceNumberRequired, Target.ysnDefaultDriverOffTruck = Source.ysnDefaultDriverOffTruck, Target.ysnAutomateTakeOutTicket = Source.ysnAutomateTakeOutTicket, Target.ysnDefaultDeductFreightFromFarmer = Source.ysnDefaultDeductFreightFromFarmer, Target.intStoreScaleOperator = Source.intStoreScaleOperator, Target.intDefaultStorageTypeId = Source.intDefaultStorageTypeId, Target.intGrainBankStorageTypeId = Source.intGrainBankStorageTypeId, Target.ysnRefreshLoadsOnOpen = Source.ysnRefreshLoadsOnOpen, Target.ysnAllowSplitWeights = Source.ysnAllowSplitWeights, Target.ysnRequireContractForInTransitTicket = Source.ysnRequireContractForInTransitTicket, Target.intDefaultFeeItemId = Source.intDefaultFeeItemId, Target.intFreightItemId = Source.intFreightItemId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intScaleSetupId, strStationShortDescription, strStationDescription, intStationType, intTicketPoolId, strAddress, strZipCode, strCity, strState, strCountry, strPhone, intLocationId, ysnAllowManualTicketNumber, strScaleOperator, intScaleProcessing, intTransferDelayMinutes, intBatchTransferInterval, strLocalFilePath, strServerPath, strWebServicePath, intMinimumPurgeDays, dtmLastPurgeDate, intLastPurgeUserId, intInScaleDeviceId, ysnDisableInScale, intOutScaleDeviceId, ysnDisableOutScale, ysnShowOutScale, ysnAllowZeroWeights, strWeightDescription, intUnitMeasureId, intGraderDeviceId, intAlternateGraderDeviceId, intLEDDeviceId, ysnCustomerFirst, intAllowOtherLocationContracts, intWeightDisplayDelay, intTicketSelectionDelay, intFreightHaulerIDRequired, intBinNumberRequired, intDriverNameRequired, intTruckIDRequired, intTrackAxleCount, intRequireSpotSalePrice, ysnTicketCommentRequired, ysnAllowElectronicSpotPrice, ysnRefreshContractsOnOpen, ysnTrackVariety, ysnManualGrading, ysnLockStoredGrade, ysnAllowManualWeight, intStorePitInformation, ysnReferenceNumberRequired, ysnDefaultDriverOffTruck, ysnAutomateTakeOutTicket, ysnDefaultDeductFreightFromFarmer, intStoreScaleOperator, intDefaultStorageTypeId, intGrainBankStorageTypeId, ysnRefreshLoadsOnOpen, ysnAllowSplitWeights, ysnRequireContractForInTransitTicket, intDefaultFeeItemId, intFreightItemId, intConcurrencyId)
            VALUES (Source.intScaleSetupId, Source.strStationShortDescription, Source.strStationDescription, Source.intStationType, Source.intTicketPoolId, Source.strAddress, Source.strZipCode, Source.strCity, Source.strState, Source.strCountry, Source.strPhone, Source.intLocationId, Source.ysnAllowManualTicketNumber, Source.strScaleOperator, Source.intScaleProcessing, Source.intTransferDelayMinutes, Source.intBatchTransferInterval, Source.strLocalFilePath, Source.strServerPath, Source.strWebServicePath, Source.intMinimumPurgeDays, Source.dtmLastPurgeDate, Source.intLastPurgeUserId, Source.intInScaleDeviceId, Source.ysnDisableInScale, Source.intOutScaleDeviceId, Source.ysnDisableOutScale, Source.ysnShowOutScale, Source.ysnAllowZeroWeights, Source.strWeightDescription, Source.intUnitMeasureId, Source.intGraderDeviceId, Source.intAlternateGraderDeviceId, Source.intLEDDeviceId, Source.ysnCustomerFirst, Source.intAllowOtherLocationContracts, Source.intWeightDisplayDelay, Source.intTicketSelectionDelay, Source.intFreightHaulerIDRequired, Source.intBinNumberRequired, Source.intDriverNameRequired, Source.intTruckIDRequired, Source.intTrackAxleCount, Source.intRequireSpotSalePrice, Source.ysnTicketCommentRequired, Source.ysnAllowElectronicSpotPrice, Source.ysnRefreshContractsOnOpen, Source.ysnTrackVariety, Source.ysnManualGrading, Source.ysnLockStoredGrade, Source.ysnAllowManualWeight, Source.intStorePitInformation, Source.ysnReferenceNumberRequired, Source.ysnDefaultDriverOffTruck, Source.ysnAutomateTakeOutTicket, Source.ysnDefaultDeductFreightFromFarmer, Source.intStoreScaleOperator, Source.intDefaultStorageTypeId, Source.intGrainBankStorageTypeId, Source.ysnRefreshLoadsOnOpen, Source.ysnAllowSplitWeights, Source.ysnRequireContractForInTransitTicket, Source.intDefaultFeeItemId, Source.intFreightItemId, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    SET IDENTITY_INSERT tblSCScaleSetup ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCScaleSetup OFF

    -- tblSCLastScaleSetup
    SET @SQLString = N'EXEC(''MERGE tblSCLastScaleSetup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCLastScaleSetup) AS Source
        ON (Target.intLastScaleSetupId = Source.intLastScaleSetupId)
        WHEN MATCHED THEN
            UPDATE SET Target.intScaleSetupId = Source.intScaleSetupId, Target.dtmScaleDate = Source.dtmScaleDate, Target.strScaleOperator = Source.strScaleOperator, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intLastScaleSetupId, intScaleSetupId, dtmScaleDate, strScaleOperator, intConcurrencyId)
            VALUES (Source.intLastScaleSetupId, Source.intScaleSetupId, Source.dtmScaleDate, Source.strScaleOperator, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCLastScaleSetup ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCLastScaleSetup OFF

    -- tblSCTicketType
    SET @SQLString = N'EXEC(''MERGE tblSCTicketType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketType) AS Source
        ON (Target.intTicketTypeId = Source.intTicketTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketPoolId = Source.intTicketPoolId, Target.intListTicketTypeId = Source.intListTicketTypeId, Target.ysnTicketAllowed = Source.ysnTicketAllowed, Target.intNextTicketNumber = Source.intNextTicketNumber, Target.intDiscountSchedule = Source.intDiscountSchedule, Target.intDiscountLocationId = Source.intDiscountLocationId, Target.intDistributionMethod = Source.intDistributionMethod, Target.ysnSelectByPO = Source.ysnSelectByPO, Target.intSplitInvoiceOption = Source.intSplitInvoiceOption, Target.intContractRequired = Source.intContractRequired, Target.intOverrideTicketCopies = Source.intOverrideTicketCopies, Target.ysnPrintAtKiosk = Source.ysnPrintAtKiosk, Target.ynsVerifySplitMethods = Source.ynsVerifySplitMethods, Target.ysnOverrideSingleTicketSeries = Source.ysnOverrideSingleTicketSeries, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketTypeId, intTicketPoolId, intListTicketTypeId, ysnTicketAllowed, intNextTicketNumber, intDiscountSchedule, intDiscountLocationId, intDistributionMethod, ysnSelectByPO, intSplitInvoiceOption, intContractRequired, intOverrideTicketCopies, ysnPrintAtKiosk, ynsVerifySplitMethods, ysnOverrideSingleTicketSeries, intConcurrencyId)
            VALUES (Source.intTicketTypeId, Source.intTicketPoolId, Source.intListTicketTypeId, Source.ysnTicketAllowed, Source.intNextTicketNumber, Source.intDiscountSchedule, Source.intDiscountLocationId, Source.intDistributionMethod, Source.ysnSelectByPO, Source.intSplitInvoiceOption, Source.intContractRequired, Source.intOverrideTicketCopies, Source.ysnPrintAtKiosk, Source.ynsVerifySplitMethods, Source.ysnOverrideSingleTicketSeries, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketType ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketType OFF

    -- tblSCListTicketTypes
    SET @SQLString = N'EXEC(''MERGE tblSCListTicketTypes AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCListTicketTypes) AS Source
        ON (Target.intTicketTypeId = Source.intTicketTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketType = Source.intTicketType, Target.strTicketType = Source.strTicketType, Target.strInOutIndicator = Source.strInOutIndicator, Target.ysnActive = Source.ysnActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketTypeId, intTicketType, strTicketType, strInOutIndicator, ysnActive, intConcurrencyId)
            VALUES (Source.intTicketTypeId, Source.intTicketType, Source.strTicketType, Source.strInOutIndicator, Source.ysnActive, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCListTicketTypes ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCListTicketTypes OFF

    -- tblSCUncompletedTicketAlert
    SET @SQLString = N'EXEC(''MERGE tblSCUncompletedTicketAlert AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCUncompletedTicketAlert) AS Source
        ON (Target.intUncompletedTicketAlertId = Source.intUncompletedTicketAlertId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intTicketUncompletedDaysAlert = Source.intTicketUncompletedDaysAlert, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intUncompletedTicketAlertId, intEntityId, intCompanyLocationId, intTicketUncompletedDaysAlert, intConcurrencyId)
            VALUES (Source.intUncompletedTicketAlertId, Source.intEntityId, Source.intCompanyLocationId, Source.intTicketUncompletedDaysAlert, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCUncompletedTicketAlert ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCUncompletedTicketAlert OFF

    -- tblSCDeviceInterfaceFile
    SET @SQLString = N'EXEC(''MERGE tblSCDeviceInterfaceFile AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCDeviceInterfaceFile) AS Source
        ON (Target.intDeviceInterfaceFileId = Source.intDeviceInterfaceFileId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intScaleDeviceId = Source.intScaleDeviceId, Target.dtmTicketVoidDateTime = Source.dtmTicketVoidDateTime, Target.strDeviceCommodity = Source.strDeviceCommodity, Target.strDeviceData = Source.strDeviceData
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDeviceInterfaceFileId, intConcurrencyId, intScaleDeviceId, dtmTicketVoidDateTime, strDeviceCommodity, strDeviceData)
            VALUES (Source.intDeviceInterfaceFileId, Source.intConcurrencyId, Source.intScaleDeviceId, Source.dtmTicketVoidDateTime, Source.strDeviceCommodity, Source.strDeviceData)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCDeviceInterfaceFile ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeviceInterfaceFile OFF

    -- tblSCDistributionOption
    SET @SQLString = N'EXEC(''MERGE tblSCDistributionOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCDistributionOption) AS Source
        ON (Target.intDistributionOptionId = Source.intDistributionOptionId)
        WHEN MATCHED THEN
            UPDATE SET Target.strDistributionOption = Source.strDistributionOption, Target.intTicketPoolId = Source.intTicketPoolId, Target.intTicketTypeId = Source.intTicketTypeId, Target.ysnDistributionAllowed = Source.ysnDistributionAllowed, Target.ysnDefaultDistribution = Source.ysnDefaultDistribution, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDistributionOptionId, strDistributionOption, intTicketPoolId, intTicketTypeId, ysnDistributionAllowed, ysnDefaultDistribution, intConcurrencyId)
            VALUES (Source.intDistributionOptionId, Source.strDistributionOption, Source.intTicketPoolId, Source.intTicketTypeId, Source.ysnDistributionAllowed, Source.ysnDefaultDistribution, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCDistributionOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDistributionOption OFF

    -- tblSCScaleDevice
    SET @SQLString = N'EXEC(''MERGE tblSCScaleDevice AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCScaleDevice) AS Source
        ON (Target.intScaleDeviceId = Source.intScaleDeviceId)
        WHEN MATCHED THEN
            UPDATE SET Target.intPhysicalEquipmentId = Source.intPhysicalEquipmentId, Target.strDeviceDescription = Source.strDeviceDescription, Target.intDeviceTypeId = Source.intDeviceTypeId, Target.intConnectionMethod = Source.intConnectionMethod, Target.strFilePath = Source.strFilePath, Target.strFileName = Source.strFileName, Target.strIPAddress = Source.strIPAddress, Target.intIPPort = Source.intIPPort, Target.intComPort = Source.intComPort, Target.intBaudRate = Source.intBaudRate, Target.intDataBits = Source.intDataBits, Target.intStopBits = Source.intStopBits, Target.intParityBits = Source.intParityBits, Target.intFlowControl = Source.intFlowControl, Target.intGraderModel = Source.intGraderModel, Target.ysnVerifyCommodityCode = Source.ysnVerifyCommodityCode, Target.ysnVerifyDateTime = Source.ysnVerifyDateTime, Target.ysnDateTimeCheck = Source.ysnDateTimeCheck, Target.ysnDateTimeFixedLocation = Source.ysnDateTimeFixedLocation, Target.intDateTimeStartingLocation = Source.intDateTimeStartingLocation, Target.intDateTimeLength = Source.intDateTimeLength, Target.strDateTimeValidationString = Source.strDateTimeValidationString, Target.ysnMotionDetection = Source.ysnMotionDetection, Target.ysnMotionFixedLocation = Source.ysnMotionFixedLocation, Target.intMotionStartingLocation = Source.intMotionStartingLocation, Target.intMotionLength = Source.intMotionLength, Target.strMotionValidationString = Source.strMotionValidationString, Target.intWeightStabilityCheck = Source.intWeightStabilityCheck, Target.ysnWeightFixedLocation = Source.ysnWeightFixedLocation, Target.intWeightStartingLocation = Source.intWeightStartingLocation, Target.intWeightLength = Source.intWeightLength, Target.strNTEPCapacity = Source.strNTEPCapacity, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intScaleDeviceId, intPhysicalEquipmentId, strDeviceDescription, intDeviceTypeId, intConnectionMethod, strFilePath, strFileName, strIPAddress, intIPPort, intComPort, intBaudRate, intDataBits, intStopBits, intParityBits, intFlowControl, intGraderModel, ysnVerifyCommodityCode, ysnVerifyDateTime, ysnDateTimeCheck, ysnDateTimeFixedLocation, intDateTimeStartingLocation, intDateTimeLength, strDateTimeValidationString, ysnMotionDetection, ysnMotionFixedLocation, intMotionStartingLocation, intMotionLength, strMotionValidationString, intWeightStabilityCheck, ysnWeightFixedLocation, intWeightStartingLocation, intWeightLength, strNTEPCapacity, intConcurrencyId)
            VALUES (Source.intScaleDeviceId, Source.intPhysicalEquipmentId, Source.strDeviceDescription, Source.intDeviceTypeId, Source.intConnectionMethod, Source.strFilePath, Source.strFileName, Source.strIPAddress, Source.intIPPort, Source.intComPort, Source.intBaudRate, Source.intDataBits, Source.intStopBits, Source.intParityBits, Source.intFlowControl, Source.intGraderModel, Source.ysnVerifyCommodityCode, Source.ysnVerifyDateTime, Source.ysnDateTimeCheck, Source.ysnDateTimeFixedLocation, Source.intDateTimeStartingLocation, Source.intDateTimeLength, Source.strDateTimeValidationString, Source.ysnMotionDetection, Source.ysnMotionFixedLocation, Source.intMotionStartingLocation, Source.intMotionLength, Source.strMotionValidationString, Source.intWeightStabilityCheck, Source.ysnWeightFixedLocation, Source.intWeightStartingLocation, Source.intWeightLength, Source.strNTEPCapacity, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCScaleDevice ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCScaleDevice OFF

    -- tblSCTicket
    SET @SQLString = N'EXEC(''MERGE tblSCTicket AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicket) AS Source
        ON (Target.intTicketId = Source.intTicketId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTicketStatus = Source.strTicketStatus, Target.strTicketNumber = Source.strTicketNumber, Target.intScaleSetupId = Source.intScaleSetupId, Target.intTicketPoolId = Source.intTicketPoolId, Target.intTicketLocationId = Source.intTicketLocationId, Target.intTicketType = Source.intTicketType, Target.strInOutFlag = Source.strInOutFlag, Target.dtmTicketDateTime = Source.dtmTicketDateTime, Target.dtmTicketTransferDateTime = Source.dtmTicketTransferDateTime, Target.dtmTicketVoidDateTime = Source.dtmTicketVoidDateTime, Target.intProcessingLocationId = Source.intProcessingLocationId, Target.strScaleOperatorUser = Source.strScaleOperatorUser, Target.intScaleOperatorId = Source.intScaleOperatorId, Target.strPurchaseOrderNumber = Source.strPurchaseOrderNumber, Target.strTruckName = Source.strTruckName, Target.strDriverName = Source.strDriverName, Target.ysnDriverOff = Source.ysnDriverOff, Target.ysnSplitWeightTicket = Source.ysnSplitWeightTicket, Target.ysnGrossManual = Source.ysnGrossManual, Target.dblGrossWeight = Source.dblGrossWeight, Target.dblGrossWeightOriginal = Source.dblGrossWeightOriginal, Target.dblGrossWeightSplit1 = Source.dblGrossWeightSplit1, Target.dblGrossWeightSplit2 = Source.dblGrossWeightSplit2, Target.dtmGrossDateTime = Source.dtmGrossDateTime, Target.intGrossUserId = Source.intGrossUserId, Target.ysnTareManual = Source.ysnTareManual, Target.dblTareWeight = Source.dblTareWeight, Target.dblTareWeightOriginal = Source.dblTareWeightOriginal, Target.dblTareWeightSplit1 = Source.dblTareWeightSplit1, Target.dblTareWeightSplit2 = Source.dblTareWeightSplit2, Target.dtmTareDateTime = Source.dtmTareDateTime, Target.intTareUserId = Source.intTareUserId, Target.dblGrossUnits = Source.dblGrossUnits, Target.dblNetUnits = Source.dblNetUnits, Target.strItemNumber = Source.strItemNumber, Target.strItemUOM = Source.strItemUOM, Target.intCustomerId = Source.intCustomerId, Target.intSplitId = Source.intSplitId, Target.strDistributionOption = Source.strDistributionOption, Target.intDiscountSchedule = Source.intDiscountSchedule, Target.strDiscountLocation = Source.strDiscountLocation, Target.dtmDeferDate = Source.dtmDeferDate, Target.strContractNumber = Source.strContractNumber, Target.intContractSequence = Source.intContractSequence, Target.strContractLocation = Source.strContractLocation, Target.dblUnitPrice = Source.dblUnitPrice, Target.dblUnitBasis = Source.dblUnitBasis, Target.dblTicketFees = Source.dblTicketFees, Target.intCurrencyId = Source.intCurrencyId, Target.dblCurrencyRate = Source.dblCurrencyRate, Target.strTicketComment = Source.strTicketComment, Target.strCustomerReference = Source.strCustomerReference, Target.ysnTicketPrinted = Source.ysnTicketPrinted, Target.ysnPlantTicketPrinted = Source.ysnPlantTicketPrinted, Target.ysnGradingTagPrinted = Source.ysnGradingTagPrinted, Target.intHaulerId = Source.intHaulerId, Target.intFreightCarrierId = Source.intFreightCarrierId, Target.dblFreightRate = Source.dblFreightRate, Target.dblFreightAdjustment = Source.dblFreightAdjustment, Target.intFreightCurrencyId = Source.intFreightCurrencyId, Target.dblFreightCurrencyRate = Source.dblFreightCurrencyRate, Target.strFreightCContractNumber = Source.strFreightCContractNumber, Target.ysnFarmerPaysFreight = Source.ysnFarmerPaysFreight, Target.strLoadNumber = Source.strLoadNumber, Target.intLoadLocationId = Source.intLoadLocationId, Target.intAxleCount = Source.intAxleCount, Target.strBinNumber = Source.strBinNumber, Target.strPitNumber = Source.strPitNumber, Target.intGradingFactor = Source.intGradingFactor, Target.strVarietyType = Source.strVarietyType, Target.strFarmNumber = Source.strFarmNumber, Target.strFieldNumber = Source.strFieldNumber, Target.strDiscountComment = Source.strDiscountComment, Target.strCommodityCode = Source.strCommodityCode, Target.intCommodityId = Source.intCommodityId, Target.intDiscountId = Source.intDiscountId, Target.intContractId = Source.intContractId, Target.intDiscountLocationId = Source.intDiscountLocationId, Target.intItemId = Source.intItemId, Target.intEntityId = Source.intEntityId, Target.intLoadId = Source.intLoadId, Target.intMatchTicketId = Source.intMatchTicketId, Target.intSubLocationId = Source.intSubLocationId, Target.intStorageLocationId = Source.intStorageLocationId, Target.intFarmFieldId = Source.intFarmFieldId, Target.intDistributionMethod = Source.intDistributionMethod, Target.intSplitInvoiceOption = Source.intSplitInvoiceOption, Target.intDriverEntityId = Source.intDriverEntityId, Target.intStorageScheduleId = Source.intStorageScheduleId, Target.intConcurrencyId = Source.intConcurrencyId, Target.dblNetWeightDestination = Source.dblNetWeightDestination, Target.ysnUseDestinationWeight = Source.ysnUseDestinationWeight, Target.ysnUseDestinationGrades = Source.ysnUseDestinationGrades, Target.ysnHasGeneratedTicketNumber = Source.ysnHasGeneratedTicketNumber, Target.intInventoryTransferId = Source.intInventoryTransferId, Target.intInventoryReceiptId = Source.intInventoryReceiptId, Target.dblGross = Source.dblGross, Target.dblShrink = Source.dblShrink, Target.dblConvertedUOMQty = Source.dblConvertedUOMQty, Target.intItemUOMIdFrom = Source.intItemUOMIdFrom, Target.intItemUOMIdTo = Source.intItemUOMIdTo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketId, strTicketStatus, strTicketNumber, intScaleSetupId, intTicketPoolId, intTicketLocationId, intTicketType, strInOutFlag, dtmTicketDateTime, dtmTicketTransferDateTime, dtmTicketVoidDateTime, intProcessingLocationId, strScaleOperatorUser, intScaleOperatorId, strPurchaseOrderNumber, strTruckName, strDriverName, ysnDriverOff, ysnSplitWeightTicket, ysnGrossManual, dblGrossWeight, dblGrossWeightOriginal, dblGrossWeightSplit1, dblGrossWeightSplit2, dtmGrossDateTime, intGrossUserId, ysnTareManual, dblTareWeight, dblTareWeightOriginal, dblTareWeightSplit1, dblTareWeightSplit2, dtmTareDateTime, intTareUserId, dblGrossUnits, dblNetUnits, strItemNumber, strItemUOM, intCustomerId, intSplitId, strDistributionOption, intDiscountSchedule, strDiscountLocation, dtmDeferDate, strContractNumber, intContractSequence, strContractLocation, dblUnitPrice, dblUnitBasis, dblTicketFees, intCurrencyId, dblCurrencyRate, strTicketComment, strCustomerReference, ysnTicketPrinted, ysnPlantTicketPrinted, ysnGradingTagPrinted, intHaulerId, intFreightCarrierId, dblFreightRate, dblFreightAdjustment, intFreightCurrencyId, dblFreightCurrencyRate, strFreightCContractNumber, ysnFarmerPaysFreight, strLoadNumber, intLoadLocationId, intAxleCount, strBinNumber, strPitNumber, intGradingFactor, strVarietyType, strFarmNumber, strFieldNumber, strDiscountComment, strCommodityCode, intCommodityId, intDiscountId, intContractId, intDiscountLocationId, intItemId, intEntityId, intLoadId, intMatchTicketId, intSubLocationId, intStorageLocationId, intFarmFieldId, intDistributionMethod, intSplitInvoiceOption, intDriverEntityId, intStorageScheduleId, intConcurrencyId, dblNetWeightDestination, ysnUseDestinationWeight, ysnUseDestinationGrades, ysnHasGeneratedTicketNumber, intInventoryTransferId, intInventoryReceiptId, dblGross, dblShrink, dblConvertedUOMQty, intItemUOMIdFrom, intItemUOMIdTo)
            VALUES (Source.intTicketId, Source.strTicketStatus, Source.strTicketNumber, Source.intScaleSetupId, Source.intTicketPoolId, Source.intTicketLocationId, Source.intTicketType, Source.strInOutFlag, Source.dtmTicketDateTime, Source.dtmTicketTransferDateTime, Source.dtmTicketVoidDateTime, Source.intProcessingLocationId, Source.strScaleOperatorUser, Source.intScaleOperatorId, Source.strPurchaseOrderNumber, Source.strTruckName, Source.strDriverName, Source.ysnDriverOff, Source.ysnSplitWeightTicket, Source.ysnGrossManual, Source.dblGrossWeight, Source.dblGrossWeightOriginal, Source.dblGrossWeightSplit1, Source.dblGrossWeightSplit2, Source.dtmGrossDateTime, Source.intGrossUserId, Source.ysnTareManual, Source.dblTareWeight, Source.dblTareWeightOriginal, Source.dblTareWeightSplit1, Source.dblTareWeightSplit2, Source.dtmTareDateTime, Source.intTareUserId, Source.dblGrossUnits, Source.dblNetUnits, Source.strItemNumber, Source.strItemUOM, Source.intCustomerId, Source.intSplitId, Source.strDistributionOption, Source.intDiscountSchedule, Source.strDiscountLocation, Source.dtmDeferDate, Source.strContractNumber, Source.intContractSequence, Source.strContractLocation, Source.dblUnitPrice, Source.dblUnitBasis, Source.dblTicketFees, Source.intCurrencyId, Source.dblCurrencyRate, Source.strTicketComment, Source.strCustomerReference, Source.ysnTicketPrinted, Source.ysnPlantTicketPrinted, Source.ysnGradingTagPrinted, Source.intHaulerId, Source.intFreightCarrierId, Source.dblFreightRate, Source.dblFreightAdjustment, Source.intFreightCurrencyId, Source.dblFreightCurrencyRate, Source.strFreightCContractNumber, Source.ysnFarmerPaysFreight, Source.strLoadNumber, Source.intLoadLocationId, Source.intAxleCount, Source.strBinNumber, Source.strPitNumber, Source.intGradingFactor, Source.strVarietyType, Source.strFarmNumber, Source.strFieldNumber, Source.strDiscountComment, Source.strCommodityCode, Source.intCommodityId, Source.intDiscountId, Source.intContractId, Source.intDiscountLocationId, Source.intItemId, Source.intEntityId, Source.intLoadId, Source.intMatchTicketId, Source.intSubLocationId, Source.intStorageLocationId, Source.intFarmFieldId, Source.intDistributionMethod, Source.intSplitInvoiceOption, Source.intDriverEntityId, Source.intStorageScheduleId, Source.intConcurrencyId, Source.dblNetWeightDestination, Source.ysnUseDestinationWeight, Source.ysnUseDestinationGrades, Source.ysnHasGeneratedTicketNumber, Source.intInventoryTransferId, Source.intInventoryReceiptId, Source.dblGross, Source.dblShrink, Source.dblConvertedUOMQty, Source.intItemUOMIdFrom, Source.intItemUOMIdTo)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicket ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicket OFF

    -- tblSCTicketDiscount
    SET @SQLString = N'EXEC(''MERGE tblSCTicketDiscount AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketDiscount) AS Source
        ON (Target.intTicketDiscountId = Source.intTicketDiscountId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketId = Source.intTicketId, Target.strDiscountCode = Source.strDiscountCode, Target.dblGradeReading = Source.dblGradeReading, Target.strCalcMethod = Source.strCalcMethod, Target.dblDiscountAmount = Source.dblDiscountAmount, Target.strShrinkWhat = Source.strShrinkWhat, Target.dblShrinkPercent = Source.dblShrinkPercent, Target.ysnGraderAutoEntry = Source.ysnGraderAutoEntry, Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketDiscountId, intTicketId, strDiscountCode, dblGradeReading, strCalcMethod, dblDiscountAmount, strShrinkWhat, dblShrinkPercent, ysnGraderAutoEntry, intDiscountScheduleCodeId, intConcurrencyId)
            VALUES (Source.intTicketDiscountId, Source.intTicketId, Source.strDiscountCode, Source.dblGradeReading, Source.strCalcMethod, Source.dblDiscountAmount, Source.strShrinkWhat, Source.dblShrinkPercent, Source.ysnGraderAutoEntry, Source.intDiscountScheduleCodeId, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketDiscount ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketDiscount OFF

    -- tblSCTicketFormat
    SET @SQLString = N'EXEC(''MERGE tblSCTicketFormat AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketFormat) AS Source
        ON (Target.intTicketFormatId = Source.intTicketFormatId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTicketFormat = Source.strTicketFormat, Target.intTicketFormatSelection = Source.intTicketFormatSelection, Target.ysnSuppressCompanyName = Source.ysnSuppressCompanyName, Target.ysnFormFeedEachCopy = Source.ysnFormFeedEachCopy, Target.strTicketHeader = Source.strTicketHeader, Target.strTicketFooter = Source.strTicketFooter, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketFormatId, strTicketFormat, intTicketFormatSelection, ysnSuppressCompanyName, ysnFormFeedEachCopy, strTicketHeader, strTicketFooter, intConcurrencyId)
            VALUES (Source.intTicketFormatId, Source.strTicketFormat, Source.intTicketFormatSelection, Source.ysnSuppressCompanyName, Source.ysnFormFeedEachCopy, Source.strTicketHeader, Source.strTicketFooter, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketFormat ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketFormat OFF

    -- tblSCTicketPool
    SET @SQLString = N'EXEC(''MERGE tblSCTicketPool AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketPool) AS Source
        ON (Target.intTicketPoolId = Source.intTicketPoolId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTicketPool = Source.strTicketPool, Target.intNextTicketNumber = Source.intNextTicketNumber, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketPoolId, strTicketPool, intNextTicketNumber, intConcurrencyId)
            VALUES (Source.intTicketPoolId, Source.strTicketPool, Source.intNextTicketNumber, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketPool ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketPool OFF

    -- tblSCTicketPrintOption
    SET @SQLString = N'EXEC(''MERGE tblSCTicketPrintOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketPrintOption) AS Source
        ON (Target.intTicketPrintOptionId = Source.intTicketPrintOptionId)
        WHEN MATCHED THEN
            UPDATE SET Target.intScaleSetupId = Source.intScaleSetupId, Target.intTicketFormatId = Source.intTicketFormatId, Target.strTicketPrintDescription = Source.strTicketPrintDescription, Target.ysnPrintCustomerCopy = Source.ysnPrintCustomerCopy, Target.ysnPrintEachSplit = Source.ysnPrintEachSplit, Target.intTicketPrintCopies = Source.intTicketPrintCopies, Target.intIssueCutCode = Source.intIssueCutCode, Target.strTicketPrinter = Source.strTicketPrinter, Target.intTicketTypeOption = Source.intTicketTypeOption, Target.strInOutIndicator = Source.strInOutIndicator, Target.intPrintingOption = Source.intPrintingOption, Target.intListTicketTypeId = Source.intListTicketTypeId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketPrintOptionId, intScaleSetupId, intTicketFormatId, strTicketPrintDescription, ysnPrintCustomerCopy, ysnPrintEachSplit, intTicketPrintCopies, intIssueCutCode, strTicketPrinter, intTicketTypeOption, strInOutIndicator, intPrintingOption, intListTicketTypeId, intConcurrencyId)
            VALUES (Source.intTicketPrintOptionId, Source.intScaleSetupId, Source.intTicketFormatId, Source.strTicketPrintDescription, Source.ysnPrintCustomerCopy, Source.ysnPrintEachSplit, Source.intTicketPrintCopies, Source.intIssueCutCode, Source.strTicketPrinter, Source.intTicketTypeOption, Source.strInOutIndicator, Source.intPrintingOption, Source.intListTicketTypeId, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketPrintOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketPrintOption OFF

    -- tblSCTicketSplit
    SET @SQLString = N'EXEC(''MERGE tblSCTicketSplit AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketSplit) AS Source
        ON (Target.intTicketSplitId = Source.intTicketSplitId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketId = Source.intTicketId, Target.intCustomerId = Source.intCustomerId, Target.dblSplitPercent = Source.dblSplitPercent, Target.strDistributionOption = Source.strDistributionOption, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketSplitId, intTicketId, intCustomerId, dblSplitPercent, strDistributionOption, intConcurrencyId)
            VALUES (Source.intTicketSplitId, Source.intTicketId, Source.intCustomerId, Source.dblSplitPercent, Source.strDistributionOption, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketSplit ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketSplit OFF

    -- tblSCTicketStorageType
    SET @SQLString = N'EXEC(''MERGE tblSCTicketStorageType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketStorageType) AS Source
        ON (Target.intTicketStorageTypeId = Source.intTicketStorageTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageNumber = Source.intStorageNumber, Target.strStorageDescription = Source.strStorageDescription, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketStorageTypeId, intStorageNumber, strStorageDescription, intConcurrencyId)
            VALUES (Source.intTicketStorageTypeId, Source.intStorageNumber, Source.strStorageDescription, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketStorageType ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketStorageType OFF

    -- tblSCTruckDriverReference
    SET @SQLString = N'EXEC(''MERGE tblSCTruckDriverReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTruckDriverReference) AS Source
        ON (Target.intTruckDriverReferenceId = Source.intTruckDriverReferenceId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strRecordType = Source.strRecordType, Target.strData = Source.strData, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTruckDriverReferenceId, intEntityId, strRecordType, strData, intConcurrencyId)
            VALUES (Source.intTruckDriverReferenceId, Source.intEntityId, Source.strRecordType, Source.strData, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTruckDriverReference ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTruckDriverReference OFF

    -- tblSCTicketCost
    SET @SQLString = N'EXEC(''MERGE tblSCTicketCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblSCTicketCost) AS Source
        ON (Target.intTicketCostId = Source.intTicketCostId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketId = Source.intTicketId, Target.intConcurrencyId = Source.intConcurrencyId, Target.intItemId = Source.intItemId, Target.intEntityVendorId = Source.intEntityVendorId, Target.strCostMethod = Source.strCostMethod, Target.dblRate = Source.dblRate, Target.intItemUOMId = Source.intItemUOMId, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketCostId, intTicketId, intConcurrencyId, intItemId, intEntityVendorId, strCostMethod, dblRate, intItemUOMId, ysnAccrue, ysnMTM, ysnPrice)
            VALUES (Source.intTicketCostId, Source.intTicketId, Source.intConcurrencyId, Source.intItemId, Source.intEntityVendorId, Source.strCostMethod, Source.dblRate, Source.intItemUOMId, Source.ysnAccrue, Source.ysnMTM, Source.ysnPrice)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;'')';

    SET IDENTITY_INSERT tblSCTicketCost ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketCost OFF

END
GO