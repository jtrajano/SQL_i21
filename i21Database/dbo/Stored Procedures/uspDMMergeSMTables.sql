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
            UPDATE SET Target.intUserRoleID = Source.intUserRoleID, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intSecurityPolicyId = Source.intSecurityPolicyId, Target.strUserName = Source.strUserName, Target.strJIRAUserName = Source.strJIRAUserName, Target.strFullName = Source.strFullName, Target.strPassword = Source.strPassword, Target.strOverridePassword = Source.strOverridePassword, Target.strDashboardRole = Source.strDashboardRole, Target.strFirstName = Source.strFirstName, Target.strMiddleName = Source.strMiddleName, Target.strLastName = Source.strLastName, Target.strPhone = Source.strPhone, Target.strDepartment = Source.strDepartment, Target.strLocation = Source.strLocation, Target.strEmail = Source.strEmail, Target.strMenuPermission = Source.strMenuPermission, Target.strMenu = Source.strMenu, Target.strForm = Source.strForm, Target.strFavorite = Source.strFavorite, Target.ysnDisabled = Source.ysnDisabled, Target.ysnAdmin = Source.ysnAdmin, Target.ysnRequirePurchasingApproval = Source.ysnRequirePurchasingApproval, Target.strDateFormat = Source.strDateFormat, Target.strNumberFormat = Source.strNumberFormat, Target.intInvalidAttempt = Source.intInvalidAttempt, Target.ysnLockedOut = Source.ysnLockedOut, Target.dtmLockOutTime = Source.dtmLockOutTime, Target.intConcurrencyId = Source.intConcurrencyId, Target.intEntityIdOld = Source.intEntityIdOld, Target.intUserSecurityIdOld = Source.intUserSecurityIdOld
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSMStartingNumber
    SET @SQLString = N'MERGE tblSMStartingNumber AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSMStartingNumber]) AS Source
        ON (Target.intStartingNumberId = Source.intStartingNumberId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTransactionType = Source.strTransactionType, Target.strPrefix = Source.strPrefix, Target.intNumber = Source.intNumber, Target.strModule = Source.strModule, Target.ysnUseLocation = Source.ysnUseLocation, Target.ysnEnable = Source.ysnEnable, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END