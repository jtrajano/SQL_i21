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
            UPDATE SET Target.strName = Source.strName, Target.strEmail = Source.strEmail, Target.strWebsite = Source.strWebsite, Target.strInternalNotes = Source.strInternalNotes, Target.ysnPrint1099 = Source.ysnPrint1099, Target.str1099Name = Source.str1099Name, 
			Target.str1099Form = Source.str1099Form, Target.str1099Type = Source.str1099Type, Target.strFederalTaxId = Source.strFederalTaxId, Target.dtmW9Signed = Source.dtmW9Signed, Target.imgPhoto = Source.imgPhoto, 
			Target.strContactNumber = Source.strContactNumber, Target.strTitle = Source.strTitle, Target.strDepartment = Source.strDepartment, Target.strMobile = Source.strMobile, Target.strPhone = Source.strPhone, 
			Target.strPhone2 = Source.strPhone2, Target.strEmail2 = Source.strEmail2, Target.strFax = Source.strFax, Target.strNotes = Source.strNotes, Target.strContactMethod = Source.strContactMethod, 
			Target.strTimezone = Source.strTimezone, Target.intLanguageId = Source.intLanguageId, Target.strEntityNo = Source.strEntityNo, Target.strContactType = Source.strContactType, Target.intDefaultLocationId = Source.intDefaultLocationId, 
			Target.ysnActive = Source.ysnActive, Target.ysnReceiveEmail = Source.ysnReceiveEmail, Target.strEmailDistributionOption = Source.strEmailDistributionOption, Target.dtmOriginationDate = Source.dtmOriginationDate, Target.strPhoneBackUp = Source.strPhoneBackUp, 
			Target.intDefaultCountryId = Source.intDefaultCountryId, Target.strDocumentDelivery = Source.strDocumentDelivery, Target.strNickName = Source.strNickName, Target.strSuffix = Source.strSuffix, Target.intEntityClassId = Source.intEntityClassId, 
			Target.strExternalERPId = Source.strExternalERPId, Target.intEntityRank = Source.intEntityRank, Target.strDateFormat = Source.strDateFormat, Target.strNumberFormat = Source.strNumberFormat, Target.intCompanyId = Source.intCompanyId, 
			Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
			INSERT (intEntityId, strName, strEmail, strWebsite, strInternalNotes, ysnPrint1099, str1099Name, str1099Form, str1099Type, strFederalTaxId, dtmW9Signed, imgPhoto, strContactNumber, strTitle, strDepartment, strMobile, strPhone, strPhone2, strEmail2, strFax, strNotes, strContactMethod, strTimezone, intLanguageId, strEntityNo, strContactType, intDefaultLocationId, ysnActive, ysnReceiveEmail, strEmailDistributionOption, dtmOriginationDate, strPhoneBackUp, intDefaultCountryId, strDocumentDelivery, strNickName, strSuffix, intEntityClassId, strExternalERPId, intEntityRank, strDateFormat, strNumberFormat, intCompanyId, intConcurrencyId)
			VALUES(Source.intEntityId, Source.strName, Source.strEmail, Source.strWebsite, Source.strInternalNotes, Source.ysnPrint1099, Source.str1099Name, Source.str1099Form, Source.str1099Type, Source.strFederalTaxId, Source.dtmW9Signed, Source.imgPhoto, Source.strContactNumber, Source.strTitle, Source.strDepartment, Source.strMobile, Source.strPhone, Source.strPhone2, Source.strEmail2, Source.strFax, Source.strNotes, Source.strContactMethod, Source.strTimezone, Source.intLanguageId, Source.strEntityNo, Source.strContactType, Source.intDefaultLocationId, Source.ysnActive, Source.ysnReceiveEmail, Source.strEmailDistributionOption, Source.dtmOriginationDate, Source.strPhoneBackUp, Source.intDefaultCountryId, Source.strDocumentDelivery, Source.strNickName, Source.strSuffix, Source.intEntityClassId, Source.strExternalERPId, Source.intEntityRank, Source.strDateFormat, Source.strNumberFormat, Source.intCompanyId, Source.intConcurrencyId)
		WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

     SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

	 SET IDENTITY_INSERT tblEMEntity ON
	 EXECUTE sp_executesql @SQLString;
	 SET IDENTITY_INSERT tblEMEntity OFF
    
	-- tblEMEntityCredential
    SET @SQLString = N'MERGE tblEMEntityCredential AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntityCredential]) AS Source
        ON (Target.intEntityCredentialId = Source.intEntityCredentialId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strUserName = Source.strUserName, Target.strPassword = Source.strPassword, Target.strApiKey = Source.strApiKey, Target.strApiSecret = Source.strApiSecret, Target.ysnApiDisabled = Source.ysnApiDisabled,
			Target.strTFASecretKey = Source.strTFASecretKey, Target.strTFACurrentCode = Source.strTFACurrentCode, Target.strTFACodeNotifMedium = Source.strTFACodeNotifMedium, Target.ysnTFAEnabled = Source.ysnTFAEnabled, Target.ysnNotEncrypted = Source.ysnNotEncrypted,
			Target.strEmail = Source.strEmail, Target.ysnEmailConfirmed = Source.ysnEmailConfirmed, Target.strPhone = Source.strPhone, Target.ysnPhoneConfirmed = Source.ysnPhoneConfirmed, Target.strSecurityStamp = Source.strSecurityStamp,
			Target.ysnTwoFactorEnabled = Source.ysnTwoFactorEnabled, Target.dtmLockoutEndDateUtc = Source.dtmLockoutEndDateUtc, Target.ysnLockoutEnabled = Source.ysnLockoutEnabled, Target.intAccessFailedCount = Source.intAccessFailedCount, 
			Target.intGridLayoutConcurrencyId = Source.intGridLayoutConcurrencyId, Target.intCompanyGridLayoutConcurrencyId = Source.intCompanyGridLayoutConcurrencyId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblEMEntityLocation
	    SET @SQLString = N'MERGE tblEMEntityLocation AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntityLocation]) AS Source
        ON (Target.intEntityLocationId = Source.intEntityLocationId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strLocationName = Source.strLocationName, Target.strAddress = Source.strAddress, Target.strCity = Source.strCity, Target.strCountry = Source.strCountry, Target.strCounty = Source.strCounty, 
			Target.strState = Source.strState, Target.strZipCode = Source.strZipCode, Target.strPhone = Source.strPhone, Target.strFax = Source.strFax, Target.strPricingLevel = Source.strPricingLevel, 
			Target.strNotes = Source.strNotes, Target.strOregonFacilityNumber = Source.strOregonFacilityNumber, Target.intShipViaId = Source.intShipViaId, Target.intTermsId = Source.intTermsId, Target.intWarehouseId = Source.intWarehouseId, 
			Target.ysnDefaultLocation = Source.ysnDefaultLocation, Target.intFreightTermId = Source.intFreightTermId, Target.intCountyTaxCodeId = Source.intCountyTaxCodeId, Target.intTaxGroupId = Source.intTaxGroupId, Target.intTaxClassId = Source.intTaxClassId, 
			Target.ysnActive = Source.ysnActive, Target.dblLongitude = Source.dblLongitude, Target.dblLatitude = Source.dblLatitude, Target.strTimezone = Source.strTimezone, Target.strCheckPayeeName = Source.strCheckPayeeName, 
			Target.intDefaultCurrencyId = Source.intDefaultCurrencyId, Target.intVendorLinkId = Source.intVendorLinkId, Target.strLocationDescription = Source.strLocationDescription, Target.strLocationType = Source.strLocationType, Target.strFarmFieldNumber = Source.strFarmFieldNumber, 
			Target.strFarmFieldDescription = Source.strFarmFieldDescription, Target.strFarmFSANumber = Source.strFarmFSANumber, Target.strFarmSplitNumber = Source.strFarmSplitNumber, Target.strFarmSplitType = Source.strFarmSplitType, Target.dblFarmAcres = Source.dblFarmAcres, 
			Target.imgFieldMapFile = Source.imgFieldMapFile, Target.strFieldMapFile = Source.strFieldMapFile, Target.ysnPrint1099 = Source.ysnPrint1099, Target.str1099Name = Source.str1099Name, Target.str1099Form = Source.str1099Form, 
			Target.str1099Type = Source.str1099Type, Target.strFederalTaxId = Source.strFederalTaxId, Target.dtmW9Signed = Source.dtmW9Signed, Target.strOriginLinkCustomer = Source.strOriginLinkCustomer, Target.intConcurrencyId = Source.intConcurrencyId,
       WHEN NOT MATCHED BY TARGET THEN
	        INSERT(intEntityLocationId, intEntityId, strLocationName, strAddress, strCity, strCountry, strCounty, strState, strZipCode, strPhone, strFax, strPricingLevel, strNotes, strOregonFacilityNumber, intShipViaId, intTermsId, intWarehouseId, ysnDefaultLocation, intFreightTermId, intCountyTaxCodeId, intTaxGroupId, intTaxClassId, ysnActive, dblLongitude, dblLatitude, strTimezone, strCheckPayeeName, intDefaultCurrencyId, intVendorLinkId, strLocationDescription, strLocationType, strFarmFieldNumber, strFarmFieldDescription, strFarmFSANumber, strFarmSplitNumber, strFarmSplitType, dblFarmAcres, imgFieldMapFile, strFieldMapFile, ysnPrint1099, str1099Name, str1099Form, str1099Type, strFederalTaxId, dtmW9Signed, strOriginLinkCustomer, intConcurrencyId)
			VALUES(Source.intEntityLocationId, Source.intEntityId, Source.strLocationName, Source.strAddress, Source.strCity, Source.strCountry, Source.strCounty, Source.strState, Source.strZipCode, Source.strPhone, Source.strFax, Source.strPricingLevel, Source.strNotes, Source.strOregonFacilityNumber, Source.intShipViaId, Source.intTermsId, Source.intWarehouseId, Source.ysnDefaultLocation, Source.intFreightTermId, Source.intCountyTaxCodeId, Source.intTaxGroupId, Source.intTaxClassId, Source.ysnActive, Source.dblLongitude, Source.dblLatitude, Source.strTimezone, Source.strCheckPayeeName, Source.intDefaultCurrencyId, Source.intVendorLinkId, Source.strLocationDescription, Source.strLocationType, Source.strFarmFieldNumber, Source.strFarmFieldDescription, Source.strFarmFSANumber, Source.strFarmSplitNumber, Source.strFarmSplitType, Source.dblFarmAcres, Source.imgFieldMapFile, Source.strFieldMapFile, Source.ysnPrint1099, Source.str1099Name, Source.str1099Form, Source.str1099Type, Source.strFederalTaxId, Source.dtmW9Signed, Source.strOriginLinkCustomer, Source.intConcurrencyId)
	     WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

	 SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

	 SET IDENTITY_INSERT tblEMEntityLocation ON
	 EXECUTE sp_executesql @SQLString;
	 SET IDENTITY_INSERT tblEMEntityLocation OFF

END