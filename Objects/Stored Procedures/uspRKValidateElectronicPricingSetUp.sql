CREATE PROCEDURE [dbo].[uspRKValidateElectronicPricingSetUp]
	 @intUserId INT
	,@ElectronicPricingSetUp INT OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strPassword NVARCHAR(100)
	DECLARE @IntinterfaceSystem INT
	DECLARE @StrQuoteProvider NVARCHAR(100)
	DECLARE @strProviderAccessType NVARCHAR(30)
	DECLARE @URL NVARCHAR(1000)
	

	SELECT @URL = strInterfaceWebServicesURL
	FROM tblSMCompanyPreference

	SELECT @strUserName = strProviderUserId
	FROM tblGRUserPreference
	WHERE [intEntityUserSecurityId] = @intUserId

	SELECT @strPassword = strProviderPassword
	FROM tblGRUserPreference
	WHERE [intEntityUserSecurityId] = @intUserId

	SELECT @StrQuoteProvider = strQuoteProvider
	FROM tblGRUserPreference
	WHERE [intEntityUserSecurityId] = @intUserId
	
	SELECT @strProviderAccessType=ISNULL(strProviderAccessType,'') 
	FROM tblGRUserPreference 
	WHERE intEntityUserSecurityId=@intUserId

	SELECT @IntinterfaceSystem = intInterfaceSystemId
	FROM tblSMCompanyPreference

	IF  ((	    @IntinterfaceSystem <> 1
			AND @IntinterfaceSystem <> 2
		)
		OR (ISNULL(@strUserName, '') = '')
		OR (ISNULL(@URL, '') = '')
		OR (ISNULL(@StrQuoteProvider, '') <> 'DTN/Agricharts')) AND @strProviderAccessType <>'History Only'
		
		BEGIN
			SET @ElectronicPricingSetUp = 0
		END
	ELSE
		BEGIN
			SET @ElectronicPricingSetUp = 1
		END
		
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspRKValidateElectronicPricingSetUp: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH