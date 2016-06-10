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
        USING (SELECT * FROM REMOTEDBSERVER.repDB.dbo.tblSMUserSecurity) AS Source
        ON (Target.intEntityUserSecurityId = Source.intEntityUserSecurityId)
        WHEN MATCHED THEN
            UPDATE SET Target.intUserRoleID = Source.intUserRoleID, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intSecurityPolicyId = Source.intSecurityPolicyId, Target.strUserName = Source.strUserName, Target.strJIRAUserName = Source.strJIRAUserName, Target.strFullName = Source.strFullName, Target.strPassword = Source.strPassword, Target.strOverridePassword = Source.strOverridePassword, Target.strDashboardRole = Source.strDashboardRole, Target.strFirstName = Source.strFirstName, Target.strMiddleName = Source.strMiddleName, Target.strLastName = Source.strLastName, Target.strPhone = Source.strPhone, Target.strDepartment = Source.strDepartment, Target.strLocation = Source.strLocation, Target.strEmail = Source.strEmail, Target.strMenuPermission = Source.strMenuPermission, Target.strMenu = Source.strMenu, Target.strForm = Source.strForm, Target.strFavorite = Source.strFavorite, Target.ysnDisabled = Source.ysnDisabled, Target.ysnAdmin = Source.ysnAdmin, Target.ysnRequirePurchasingApproval = Source.ysnRequirePurchasingApproval, Target.strDateFormat = Source.strDateFormat, Target.strNumberFormat = Source.strNumberFormat, Target.dtmLastChangePassword = Source.dtmLastChangePassword, Target.intInvalidAttempt = Source.intInvalidAttempt, Target.ysnLockedOut = Source.ysnLockedOut, Target.dtmLockOutTime = Source.dtmLockOutTime, Target.intConcurrencyId = Source.intConcurrencyId, Target.intEntityIdOld = Source.intEntityIdOld, Target.intUserSecurityIdOld = Source.intUserSecurityIdOld
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intEntityUserSecurityId, intUserRoleID, intCompanyLocationId, intSecurityPolicyId, strUserName, strJIRAUserName, strFullName, strPassword, strOverridePassword, strDashboardRole, strFirstName, strMiddleName, strLastName, strPhone, strDepartment, strLocation, strEmail, strMenuPermission, strMenu, strForm, strFavorite, ysnDisabled, ysnAdmin, ysnRequirePurchasingApproval, strDateFormat, strNumberFormat, dtmLastChangePassword, intInvalidAttempt, ysnLockedOut, dtmLockOutTime, intConcurrencyId, intEntityIdOld, intUserSecurityIdOld)
            VALUES (Source.intEntityUserSecurityId, Source.intUserRoleID, Source.intCompanyLocationId, Source.intSecurityPolicyId, Source.strUserName, Source.strJIRAUserName, Source.strFullName, Source.strPassword, Source.strOverridePassword, Source.strDashboardRole, Source.strFirstName, Source.strMiddleName, Source.strLastName, Source.strPhone, Source.strDepartment, Source.strLocation, Source.strEmail, Source.strMenuPermission, Source.strMenu, Source.strForm, Source.strFavorite, Source.ysnDisabled, Source.ysnAdmin, Source.ysnRequirePurchasingApproval, Source.strDateFormat, Source.strNumberFormat, Source.dtmLastChangePassword, Source.intInvalidAttempt, Source.ysnLockedOut, Source.dtmLockOutTime, Source.intConcurrencyId, Source.intEntityIdOld, Source.intUserSecurityIdOld)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END