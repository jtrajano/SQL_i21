CREATE PROCEDURE [dbo].[uspSMDuplicateLicense]
	@strUniqueId NVARCHAR(40),
	@intCustomerLicenseInformationId INT,
	@newCustomerLicenseInformationId INT OUTPUT
AS
BEGIN

	DECLARE @intCount INT

	SELECT @intCount = COUNT(*) FROM [tblARCustomerLicenseInformation] WHERE [strDescription] LIKE 'DUP: ' + (SELECT [strDescription] FROM [tblARCustomerLicenseInformation] WHERE intCustomerLicenseInformationId = @intCustomerLicenseInformationId) + '%' 

	INSERT tblARCustomerLicenseInformation([strUniqueId],
	[strVersion],
	[intEntityCustomerId],
	[strCompanyId],
	[intNumberOfAdmin],
	[intNumberOfUser],
	[intMaxStores],
	[intMaxConsignmentStores],
	[intPowerBIRefreshes],
	[strDescription],
	[strURL],
	[ysnExternalAccess],
	[strType],
	[intNumberOfSite],
	[dtmDateIssued],
	[dtmDateExpiration],
	[dtmSupportExpiration],
	[strLicenseKey],
	[ysnNew])
	SELECT @strUniqueId,
	[strVersion],
	[intEntityCustomerId],
	[strCompanyId],
	[intNumberOfAdmin],
	[intNumberOfUser],
	[intMaxStores],
	[intMaxConsignmentStores],
	CASE WHEN ISNULL([intPowerBIRefreshes], 0) <> 0 THEN [intPowerBIRefreshes] ELSE 4 END,
	CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strDescription] 
		   ELSE 'DUP: ' + [strDescription] + ' (' + CAST(@intCount AS NVARCHAR) + ')' END,
	[strURL],
	[ysnExternalAccess],
	[strType],
	[intNumberOfSite],
	GETDATE(),
	[dtmDateExpiration],
	[dtmSupportExpiration],
	[strLicenseKey],
	1
	FROM tblARCustomerLicenseInformation 
	WHERE intCustomerLicenseInformationId = @intCustomerLicenseInformationId;
	
	SELECT @newCustomerLicenseInformationId = SCOPE_IDENTITY();

	INSERT INTO tblARCustomerLicenseModule([intCustomerLicenseInformationId], [intModuleId], [strModuleName], [ysnEnabled])
	SELECT @newCustomerLicenseInformationId, [intModuleId], [strModuleName], [ysnEnabled]
	FROM tblARCustomerLicenseModule
	WHERE intCustomerLicenseInformationId = @intCustomerLicenseInformationId

	INSERT INTO tblSMLicenseSavedFeature([intCustomerLicenseInformationId], [strKey], [strValue], [intConcurrencyId])
	SELECT @newCustomerLicenseInformationId, [strKey], [strValue], 1
	FROM tblSMLicenseSavedFeature
	WHERE intCustomerLicenseInformationId = @intCustomerLicenseInformationId
END