CREATE PROCEDURE [dbo].[uspDMMergeSMTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

	-- tblSMUserSecurity
    SET @SQLString = N'MERGE tblSMUserSecurity AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSMUserSecurity]) AS Source
        ON (Target.intEntityId = Source.intEntityId)
        WHEN MATCHED THEN
			UPDATE SET Target.intUserRoleID = Source.intUserRoleID, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intSecurityPolicyId = Source.intSecurityPolicyId, Target.strUserName = Source.strUserName, Target.strJIRAUserName = Source.strJIRAUserName, Target.strFullName = Source.strFullName,
			Target.strPassword = Source.strPassword, Target.strOverridePassword = Source.strOverridePassword, Target.strDashboardRole = Source.strDashboardRole, Target.strFirstName = Source.strFirstName, Target.strMiddleName = Source.strMiddleName,
			Target.strLastName = Source.strLastName, Target.strPhone = Source.strPhone, Target.strDepartment = Source.strDepartment, Target.strLocation = Source.strLocation, Target.strEmail = Source.strEmail,
			Target.strMenuPermission = Source.strMenuPermission, Target.strMenu = Source.strMenu, Target.strForm = Source.strForm, Target.strFavorite = Source.strFavorite, Target.ysnDisabled = Source.ysnDisabled,
			Target.ysnAdmin = Source.ysnAdmin, Target.ysnRequirePurchasingApproval = Source.ysnRequirePurchasingApproval, Target.strDateFormat = Source.strDateFormat, Target.strNumberFormat = Source.strNumberFormat, Target.intInvalidAttempt = Source.intInvalidAttempt,
			Target.ysnLockedOut = Source.ysnLockedOut, Target.dtmLockOutTime = Source.dtmLockOutTime, Target.strEmployeeOriginId = Source.strEmployeeOriginId, Target.ysnStoreManager = Source.ysnStoreManager, Target.dtmScaleDate = Source.dtmScaleDate,
			Target.intEntityScaleOperatorId = Source.intEntityScaleOperatorId, Target.intConcurrencyId = Source.intConcurrencyId, Target.intEntityIdOld = Source.intEntityIdOld, Target.intUserSecurityIdOld = Source.intUserSecurityIdOld, Target.ysnSecurityPolicyUpdated = Source.ysnSecurityPolicyUpdated
		WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';
    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSMStartingNumber
    SET @SQLString = N'MERGE tblSMStartingNumber AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSMStartingNumber]) AS Source
        ON (Target.intStartingNumberId = Source.intStartingNumberId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTransactionType = Source.strTransactionType, Target.strPrefix = Source.strPrefix, Target.intNumber = Source.intNumber, Target.intDigits = Source.intDigits, Target.strModule = Source.strModule, Target.ysnUseLocation = Source.ysnUseLocation, Target.ysnEnable = Source.ysnEnable, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';
    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

	--tblSMFreightTerms
    SET @SQLString = N'MERGE tblSMFreightTerms AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSMFreightTerms]) AS Source
        ON (Target.intFreightTermId = Source.intFreightTermId)
        WHEN MATCHED THEN
            UPDATE SET Target.strFreightTerm = Source.strFreightTerm, Target.strFobPoint = Source.strFobPoint, Target.ysnActive = Source.ysnActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
	       INSERT (intFreightTermId, strFreightTerm, strFobPoint, ysnActive, intConcurrencyId)
		   VALUES (Source.intFreightTermId, Source.strFreightTerm, Source.strFobPoint, Source.ysnActive, Source.intConcurrencyId)
	    WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';
     SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
	 SET IDENTITY_INSERT tblSMFreightTerms ON
	 EXECUTE sp_executesql @SQLString;
	 SET IDENTITY_INSERT tblSMFreightTerms OFF

	 --tblSMShipVia
    SET @SQLString = N'MERGE tblSMShipVia AS Target
	  USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSMShipVia]) AS Source
	  ON (Target.intEntityId = Source.intEntityId)
	  WHEN MATCHED THEN
		UPDATE SET Target.intEntityId = Source.intEntityId, Target.strShipViaOriginKey = Source.strShipViaOriginKey, Target.strShipVia = Source.strShipVia, Target.strShippingService = Source.strShippingService, Target.strName = Source.strName, Target.strAddress = Source.strAddress,
		Target.strCity = Source.strCity, Target.strState = Source.strState, Target.strZipCode = Source.strZipCode, Target.strFederalId = Source.strFederalId, Target.strTransporterLicense = Source.strTransporterLicense,
		Target.strMotorCarrierIFTA = Source.strMotorCarrierIFTA, Target.strTransportationMode = Source.strTransportationMode, Target.ysnCompanyOwnedCarrier = Source.ysnCompanyOwnedCarrier, Target.strFreightBilledBy = Source.strFreightBilledBy, Target.ysnActive = Source.ysnActive,
		Target.intSort = Source.intSort, Target.intConcurrencyId = Source.intConcurrencyId
      WHEN NOT MATCHED BY TARGET THEN
	      INSERT (intEntityId, strShipViaOriginKey, strShipVia, strShippingService, strName, strAddress, strCity, strState, strZipCode, strFederalId, strTransporterLicense, strMotorCarrierIFTA, strTransportationMode, ysnCompanyOwnedCarrier, strFreightBilledBy, ysnActive, intSort, intConcurrencyId)
			  VALUES(Source.intEntityId, Source.strShipViaOriginKey, Source.strShipVia, Source.strShippingService, Source.strName, Source.strAddress, Source.strCity, Source.strState, Source.strZipCode, Source.strFederalId, Source.strTransporterLicense, Source.strMotorCarrierIFTA, Source.strTransportationMode, Source.ysnCompanyOwnedCarrier, Source.strFreightBilledBy, Source.ysnActive, Source.intSort, Source.intConcurrencyId)
	  WHEN NOT MATCHED BY SOURCE THEN
			DELETE;'
    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END