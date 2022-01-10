CREATE PROCEDURE [dbo].[uspApiSchemaTransformEntity]
	  @guiApiUniqueId UNIQUEIDENTIFIER
    , @guiLogId UNIQUEIDENTIFIER
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @EmailDistribution NVARCHAR(MAX)
DECLARE @EmailDistributionList NVARCHAR(MAX)
DECLARE @EmailDistributionValid NVARCHAR(MAX)
DECLARE @EmailDistributionInvalid NVARCHAR(MAX)
DECLARE @UserRoleId INT


SET @EmailDistributionList
    = 'Invoices,Transport Quote,Statements,AP remittance,AR Remittance,Contracts,Sales Order,Credit Memo,Quote Order,Scale,Storage,Cash,Cash Refund,Debit Memo,Customer Prepayment,CF Invoice,Letter,PR Remittance,Dealer CC Notification,Purchase Order,Settlement'
SET @EmailDistribution = '@emailDistribution@'
select @EmailDistributionInvalid = COALESCE(@EmailDistributionInvalid + ',', '') + RTRIM(LTRIM(invalid.Item)) from tblApiSchemaEMEntity SC
OUTER APPLY(
SELECT a.Item FROM dbo.fnSplitString(SC.strEmailDistributionOption, ',') a
    left join dbo.fnSplitString(@EmailDistributionList, ',') b
        on ltrim(rtrim(a.Item)) = b.Item
		where b.Item is null
)invalid
SET @EmailDistributionInvalid = ISNULL(@EmailDistributionInvalid, '')

-- VALIDATE
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Number'
    , strValue = SC.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Customer Number is blank.'
FROM tblApiSchemaEMEntity SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(strEntityNo, ''))) = '' 


INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Name'
    , strValue = SC.strName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Customer Name is blank.'
FROM tblApiSchemaEMEntity SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(strName, ''))) = '' 


INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Portal User Role'
    , strValue = SC.strLocationName
    , strLogLevel = 'Info'
    , strStatus = ''
    , intRowNo = SC.intRowNumber
    , strMessage = 'The Location Name of ' + SC.strLocationName + ' was not found.'
FROM tblApiSchemaEMEntity SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND strPortalUserRole   IN  (SELECT TOP 1 strLocationName 
    FROM tblEMEntityLocation
    where intEntityId = intEntityId
          and rtrim(ltrim(lower(SC.strLocationName))) = rtrim(ltrim(lower(strLocationName))))


INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Email Distribution'
    , strValue = SC.strEmailDistributionOption
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Email Distribution [' + SC.strEmailDistributionOption + '] has been exluded for the email distribution'
FROM tblApiSchemaEMEntity SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND ISNULL(@EmailDistributionInvalid, '') <> ''


INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Contact Method'
    , strValue = SC.strContactMethod
    , strLogLevel = 'Error'
    , strStatus = ''
    , intRowNo = SC.intRowNumber
    , strMessage = 'Contact Method [' + strContactMethod + '] setting it to Blank'
FROM tblApiSchemaEMEntity SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND  strContactMethod NOT IN ( 'Email', 'Phone', 'Email or Phone' )


INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Portal User Role'
    , strValue = SC.strPortalUserRole
    , strLogLevel = 'Info'
    , strStatus = ''
    , intRowNo = SC.intRowNumber
    , strMessage = 'The User Role of ' + SC.strPortalUserRole + ' was not found in the Portal User Role. Please add this Role from the System Manager screen and re-attempt the upload'
FROM tblApiSchemaEMEntity SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND strPortalUserRole   IN  (SELECT TOP 1 strName
    FROM dbo.tblSMUserRole
    WHERE strName = SC.strPortalUserRole)

UPDATE tblApiSchemaEMEntity set  strContactMethod = '' WHERE guiApiUniqueId = @guiApiUniqueId AND strContactMethod NOT IN ( 'Email', 'Phone', 'Email or Phone' )


IF OBJECT_ID(N'tempdb..#tblContact') IS NOT NULL
BEGIN
DROP TABLE #tblContact
END

CREATE TABLE #tblContact
(
    [guiApiUniqueId] [uniqueidentifier] NOT NULL,
	[intRowNumber] [int] NULL,
	[intKey] [int]  NOT NULL,
	[strEntityNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strName] [nvarchar](100) NOT NULL,
	[strMobile] [nvarchar](20)  NULL,
	[strLocationName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strPhone] [nvarchar](100) NULL,
	[strEmail] [nvarchar](75) NULL,
	[strSuffix] [nvarchar](50) NULL,	
	[strTitle] [nvarchar](255) NULL,
	[strNickName] [nvarchar](100) NULL,
	[strDepartment] [nvarchar](30) NULL,
	[strNotes] [nvarchar](max) NULL,
	[intEntityRank] [int]  NULL,
	[ysnActive] [bit]  NULL,
	[strContactMethod] [nvarchar](20) NULL,
	[strEmailDistributionOption] [nvarchar](max) NULL,
	[strPortalUserRole] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL ,
	[strPortalPassword] [nvarchar](100) NULL,
	[intRow] [int] IDENTITY(1,1) NOT NULL,
)


INSERT INTO #tblContact
select * from tblApiSchemaEMEntity


IF NOT EXISTS (SELECT top 1 1 FROM tblApiImportLogDetail Where strMessage <> '' AND  guiApiImportLogId = @guiLogId)
BEGIN 
	DECLARE @NewEntityId INT,@intRow INT
	WHILE EXISTS (SELECT TOP 1 NULL FROM #tblContact)  
    BEGIN  
	
		
	 SELECT TOP 1 @intRow    = intRow
     FROM #tblContact  
    INSERT INTO tblEMEntity
    (
        strName,
        strMobile,
        strEmail,
        strSuffix,
        strTitle,
        strNickName,
        strDepartment,
        strNotes,
        intEntityRank,
        ysnActive,
        strContactMethod,
        strEmailDistributionOption,
		strContactNumber
    )
    SELECT strName,
           strMobile,
           strEmail,
           strSuffix,
           strTitle,
           strNickName,
           strDepartment,
           strNotes,
           ISNULL(intEntityRank, 1),
           ysnActive,
           strContactMethod,
           strEmailDistributionOption,
		   ''
	FROM #tblContact WHERE [guiApiUniqueId] = @guiApiUniqueId AND intRow= @intRow

    SET @NewEntityId = @@IDENTITY 

    INSERT INTO tblEMEntityToContact
    (
        intEntityId,
        intEntityContactId,
        ysnPortalAccess,
        intEntityLocationId
    )
    SELECT C.intEntityId,
           @NewEntityId,
           0,
           L.intEntityLocationId
		FROM #tblContact A
		INNER JOIN tblARCustomer C ON A.strEntityNo = C.strCustomerNumber
		LEFT JOIN tblEMEntityLocation L ON A.strLocationName = L.strLocationName
		WHERE A.guiApiUniqueId = @guiApiUniqueId   AND intRow= @intRow

     INSERT INTO tblEMEntityPhoneNumber
        (
            intEntityId,
            strPhone
        )
        SELECT @NewEntityId,
               strPhone
	 FROM tblApiSchemaEMEntity   WHERE guiApiUniqueId = @guiApiUniqueId  AND strPhone <> ''


	    INSERT INTO tblEMEntityMobileNumber
        (
            intEntityId,
            strPhone
        )
        SELECT @NewEntityId,
               strMobile
	 FROM tblApiSchemaEMEntity   WHERE guiApiUniqueId = @guiApiUniqueId  AND strMobile <> ''

	  DELETE FROM #tblContact WHERE intRow = @intRow  

	  END
  END