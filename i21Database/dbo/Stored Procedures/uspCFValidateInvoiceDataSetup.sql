
CREATE PROCEDURE [dbo].[uspCFValidateInvoiceDataSetup](
	@strUserId  NVARCHAR(MAX)
)
AS
BEGIN


	DECLARE @tblResultTable AS TABLE
	(
		intId			INT IDENTITY
		,strSetup		NVARCHAR(MAX)
		,strValue		NVARCHAR(MAX)
		,strSetupIssue	NVARCHAR(MAX)
	)


	--------ITEM LOCATION VALIDATION----------
	DECLARE @tblValidateItemResultTable AS TABLE
	(
		 intItemId				INT
		,strItemNo				NVARCHAR(MAX)
		,strDescription			NVARCHAR(MAX)
		,ysnLocationSetupExist	BIT
	)

	DECLARE @intCFLocationPreference INT
	SELECT TOP 1 @intCFLocationPreference = intARLocationId FROM tblCFCompanyPreference

	INSERT INTO @tblValidateItemResultTable
	(
		 intItemId			
		,strItemNo			
		,strDescription		
		,ysnLocationSetupExist
	)
	SELECT 
	 tblICItem.intItemId
	,tblICItem.strItemNo
	,tblICItem.strDescription 
	,ysnLocationSetupExist = (SELECT TOP 1 COUNT(1) FROM tblICItemLocation WHERE intItemId = tblCFInvoiceFeeStagingTable.intItemId AND tblICItemLocation.intLocationId = @intCFLocationPreference)
	FROM tblCFInvoiceFeeStagingTable  
	INNER JOIN tblICItem
	ON tblICItem.intItemId = tblCFInvoiceFeeStagingTable.intItemId
	WHERE strUserId = @strUserId

	--INSERT ITEM SETUP ISSUE--
	INSERT INTO @tblResultTable
	(
		 strSetup		
		,strValue		
		,strSetupIssue
	)
	SELECT
		'Item' 
		, CAST(strItemNo AS nvarchar(max)) + ' - ' + strDescription
		, 'Item location is not setup for fee items for the CF invoice company location'
	FROM @tblValidateItemResultTable WHERE ISNULL(ysnLocationSetupExist,0) = 0
	--------ITEM LOCATION VALIDATION----------


	--------INVALID CUSTOMER----------
	INSERT INTO @tblResultTable
	(
		 strSetup		
		,strValue		
		,strSetupIssue
	)
	SELECT
		'Customer' 
		, CAST(tblCFInvoiceStagingTable.strCustomerNumber AS nvarchar(max)) + ' - ' + tblCFInvoiceStagingTable.strCustomerName
		, 'Customer is in-active'
	FROM tblCFInvoiceStagingTable
	INNER JOIN tblARCustomer 
	ON tblARCustomer.intEntityId = tblCFInvoiceStagingTable.intCustomerId 
	WHERE strUserId = @strUserId
	AND ISNULL(tblARCustomer.ysnActive,0) = 0
	--------INVALID CUSTOMER----------


	--------OUTPUT----------
	SELECT * FROM @tblResultTable
    
END

