CREATE PROCEDURE [dbo].[uspARValidateItemLicense]
	  @intEntityCustomerId		INT
	, @intEntityApplicatorId	INT	= NULL
	, @dtmDate					DATETIME = NULL
	, @strItemIds				NVARCHAR(MAX) = NULL
	, @strErrorMessage			NVARCHAR(MAX) = NULL	OUTPUT
AS

IF(OBJECT_ID('tempdb..#ITEMSTOVALIDATE') IS NOT NULL)
BEGIN
    DROP TABLE #ITEMSTOVALIDATE
END

IF ISNULL(@intEntityCustomerId, 0) = 0
	BEGIN
		SET @strErrorMessage = 'Customer is required for validating Item''s License'
		RETURN 0
	END

IF @dtmDate IS NULL
	BEGIN
		SET @strErrorMessage = 'Transaction Date is required.'
		RETURN 0
	END

SELECT intItemId					= I.intItemId	 
	 , intLicenseTypeId				= IL.intLicenseTypeId
	 , intEntityCustomerId			= CML.intEntityCustomerId
	 , strItemNo					= I.strItemNo
	 , strCode						= LT.strCode
	 , strDescription				= LT.strDescription
	 , ysnRequiredForApplication	= LT.ysnRequiredForApplication
	 , ysnRequiredForPurchase		= LT.ysnRequiredForPurchase
	 , dtmBeginDate					= CML.dtmBeginDate
	 , dtmEndDate					= CML.dtmEndDate
INTO #ITEMSTOVALIDATE
FROM dbo.tblICItem I WITH (NOLOCK)
INNER JOIN (
	SELECT intID
	FROM fnGetRowsFromDelimitedValues(@strItemIds)
) ITEMS ON I.intItemId = ITEMS.intID
INNER JOIN (
	SELECT intItemId
		 , intLicenseTypeId
	FROM dbo.tblICItemLicense WITH (NOLOCK)
) IL ON I.intItemId = IL.intItemId
INNER JOIN (
	SELECT intLicenseTypeId
		 , strCode
		 , strDescription
		 , ysnRequiredForApplication
		 , ysnRequiredForPurchase
	FROM dbo.tblSMLicenseType WITH (NOLOCK)
) LT ON IL.intLicenseTypeId = LT.intLicenseTypeId
LEFT JOIN (
	SELECT intEntityCustomerId
		 , intLicenseTypeId
		 , dtmBeginDate
		 , dtmEndDate				 
	FROM dbo.tblARCustomerMasterLicense WITH (NOLOCK)
	WHERE ysnAcvite = 1
		AND intEntityCustomerId = @intEntityCustomerId
) CML ON ITEMS.intLicenseTypeId = CML.intLicenseTypeId

SET @strErrorMessage = NULL

WHILE EXISTS (SELECT TOP 1 NULL FROM #ITEMSTOVALIDATE)
	BEGIN
		DECLARE @intItemId					INT = NULL
			  , @intCustomerId				INT = NULL
			  , @strItemNo					NVARCHAR(200)	= NULL
			  , @strCode					NVARCHAR(200)	= NULL
			  , @dtmDateFrom				DATETIME = NULL
			  , @dtmDateTo					DATETIME = NULL
			  , @ysnRequiredForApplication	BIT = NULL
			  
		SELECT TOP 1 @intItemId					= intItemId
				   , @intCustomerId				= intEntityCustomerId
				   , @strItemNo					= ISNULL(strItemNo, '')
				   , @strCode					= ISNULL(strCode, '')
				   , @dtmDateFrom				= ISNULL(dtmBeginDate, '01/01/1900')
				   , @dtmDateTo					= ISNULL(dtmEndDate, '12/30/2999')
				   , @ysnRequiredForApplication = ISNULL(ysnRequiredForApplication, 0)
		FROM #ITEMSTOVALIDATE 		
		ORDER BY intItemId

		--Validate if Customer has Active License
		IF ISNULL(@intCustomerId, 0) = 0
			SET @strErrorMessage = ISNULL(@strErrorMessage, '') + @strCode + ' License is required for item ' + @strItemNo + CHAR(13)
		ELSE
			BEGIN
				--Validate if Customer's License is 
				IF (@dtmDate NOT BETWEEN @dtmDateTo AND @dtmDateFrom)
					SET @strErrorMessage = ISNULL(@strErrorMessage, '') + @strCode + ' License is already expired for item ' + @strItemNo + CHAR(13)

				IF (@ysnRequiredForApplication = 1 AND ISNULL(@intEntityApplicatorId, 0) = 0)
					SET @strErrorMessage = ISNULL(@strErrorMessage, '') + 'Applicator is required for ' + @strCode + ' License in item ' + @strItemNo + CHAR(13)
			END

		DELETE FROM #ITEMSTOVALIDATE WHERE intItemId = @intItemId
	END