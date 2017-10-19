CREATE PROCEDURE [dbo].[uspDMMergeEMTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

    -- tblEMEntity
    SET @SQLString = N'MERGE tblEMEntity AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntity]) AS Source
        ON (Target.intEntityId = Source.intEntityId)
        WHEN MATCHED THEN
            UPDATE SET Target.strName = Source.strName, Target.strEmail = Source.strEmail, Target.strWebsite = Source.strWebsite, Target.strInternalNotes = Source.strInternalNotes, Target.ysnPrint1099 = Source.ysnPrint1099, Target.str1099Name = Source.str1099Name, Target.str1099Form = Source.str1099Form, Target.str1099Type = Source.str1099Type, Target.strFederalTaxId = Source.strFederalTaxId, Target.dtmW9Signed = Source.dtmW9Signed, Target.imgPhoto = Source.imgPhoto, Target.strContactNumber = Source.strContactNumber, Target.strTitle = Source.strTitle, Target.strDepartment = Source.strDepartment, Target.strMobile = Source.strMobile, Target.strPhone = Source.strPhone, Target.strPhone2 = Source.strPhone2, Target.strEmail2 = Source.strEmail2, Target.strFax = Source.strFax, Target.strNotes = Source.strNotes, Target.strContactMethod = Source.strContactMethod, Target.strTimezone = Source.strTimezone, Target.strEntityNo = Source.strEntityNo, Target.strContactType = Source.strContactType, Target.intDefaultLocationId = Source.intDefaultLocationId, Target.ysnActive = Source.ysnActive, Target.ysnReceiveEmail = Source.ysnReceiveEmail, Target.strEmailDistributionOption = Source.strEmailDistributionOption, Target.dtmOriginationDate = Source.dtmOriginationDate, Target.strPhoneBackUp = Source.strPhoneBackUp, Target.intDefaultCountryId = Source.intDefaultCountryId, Target.strDocumentDelivery = Source.strDocumentDelivery, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblEMEntityCredential
    SET @SQLString = N'MERGE tblEMEntityCredential AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntityCredential]) AS Source
        ON (Target.intEntityCredentialId = Source.intEntityCredentialId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strUserName = Source.strUserName, Target.strPassword = Source.strPassword, Target.strApiKey = Source.strApiKey, Target.strApiSecret = Source.strApiSecret, Target.ysnApiDisabled = Source.ysnApiDisabled, Target.strTFASecretKey = Source.strTFASecretKey, Target.strTFACurrentCode = Source.strTFACurrentCode, Target.strTFACodeNotifMedium = Source.strTFACodeNotifMedium, Target.ysnTFAEnabled = Source.ysnTFAEnabled, Target.ysnNotEncrypted = Source.ysnNotEncrypted, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblEMEntityLocation
    SET @SQLString = N'MERGE tblEMEntityLocation AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntityLocation]) AS Source
        ON (Target.intEntityLocationId = Source.intEntityLocationId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strLocationName = Source.strLocationName, Target.strAddress = Source.strAddress, Target.strCity = Source.strCity, Target.strCountry = Source.strCountry, Target.strState = Source.strState, Target.strZipCode = Source.strZipCode, Target.strPhone = Source.strPhone, Target.strFax = Source.strFax, Target.strPricingLevel = Source.strPricingLevel, Target.strNotes = Source.strNotes, Target.intShipViaId = Source.intShipViaId, Target.intTermsId = Source.intTermsId, Target.intWarehouseId = Source.intWarehouseId, Target.ysnDefaultLocation = Source.ysnDefaultLocation, Target.intFreightTermId = Source.intFreightTermId, Target.intCountyTaxCodeId = Source.intCountyTaxCodeId, Target.intTaxGroupId = Source.intTaxGroupId, Target.intTaxClassId = Source.intTaxClassId, Target.ysnActive = Source.ysnActive, Target.dblLongitude = Source.dblLongitude, Target.dblLatitude = Source.dblLatitude, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END