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
) CML ON IL.intLicenseTypeId = CML.intLicenseTypeId

SET @strErrorMessage = NULL

--MDG this is not a good approach but for now this will consolidate the error message per license
insert into #ITEMSTOVALIDATE
( intItemId, intLicenseTypeId, intEntityCustomerId, strItemNo, strCode, strDescription, ysnRequiredForApplication, ysnRequiredForPurchase, dtmBeginDate, dtmEndDate)
select e.intItemId, -9, -999, e.strItemNo,
stuff((
			select ', ' + coalesce(ltrim(rtrim(f.strCode)), '') 
				from #ITEMSTOVALIDATE f
						where f.strItemNo= e.strItemNo
for xml path('') ), 1, 1, '') as strCode
, ''
, 1
, 1
, null
, null

from #ITEMSTOVALIDATE e 
	where isnull(e.intEntityCustomerId,0) = 0

delete from  #ITEMSTOVALIDATE where isnull(intEntityCustomerId,0) = 0
update #ITEMSTOVALIDATE set intEntityCustomerId = null where intEntityCustomerId = -999



WHILE EXISTS (SELECT TOP 1 NULL FROM #ITEMSTOVALIDATE)
	BEGIN
		DECLARE @intItemId					INT = NULL
			  , @intLicenseTypeId			INT = NULL
			  , @intCustomerId				INT = NULL
			  , @strItemNo					NVARCHAR(200)	= NULL
			  , @strCode					NVARCHAR(200)	= NULL
			  , @dtmDateFrom				DATETIME = NULL
			  , @dtmDateTo					DATETIME = NULL
			  , @ysnRequiredForApplication	BIT = NULL
			  
		SELECT TOP 1 @intItemId					= intItemId
			       , @intLicenseTypeId			= intLicenseTypeId
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
			SET @strErrorMessage = ISNULL(@strErrorMessage, '') + @strCode + ' License is required for item ' + @strItemNo + '<br>'
		ELSE
			BEGIN
				--Validate if Customer's License is 
				IF (@dtmDate NOT BETWEEN @dtmDateFrom AND @dtmDateTo)
					SET @strErrorMessage = ISNULL(@strErrorMessage, '') + @strCode + ' License is already expired for item ' + @strItemNo + '<br>'

				IF (@ysnRequiredForApplication = 1 AND ISNULL(@intEntityApplicatorId, 0) = 0)
					SET @strErrorMessage = ISNULL(@strErrorMessage, '') + 'Applicator is required for ' + @strCode + ' License in item ' + @strItemNo + '<br>'
			END

		DELETE FROM #ITEMSTOVALIDATE WHERE intItemId = @intItemId AND intLicenseTypeId = @intLicenseTypeId
	END