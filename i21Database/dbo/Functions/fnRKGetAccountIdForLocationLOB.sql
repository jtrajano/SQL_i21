CREATE FUNCTION [dbo].[fnRKGetAccountIdForLocationLOB]
(
	@strCategory NVARCHAR(100)
	, @intAccountId INT
	, @intCommodityId INT
	, @intLocationId INT
)
RETURNS @tblAccount TABLE (
	intAccountId INT
	, strAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, ysnHasError BIT
	, strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)

AS

BEGIN
	DECLARE @strCommodityCode NVARCHAR(50) = ''
		, @ErrMsg NVARCHAR(MAX) = ''
		, @intFinalAccountId INT
		, @strFinalAccountId NVARCHAR(50) = ''
		, @ysnUseCompanyPrefGL INT

	SELECT TOP 1 @ysnUseCompanyPrefGL = intPostToGLId FROM tblRKCompanyPreference

	IF (ISNULL(@intAccountId, 0) = 0) 
	BEGIN
		SELECT @ErrMsg = @strCategory + ' cannot be blank. Please set up the default account in ' + (CASE WHEN @ysnUseCompanyPrefGL = 1 THEN 'Company Configuration Risk Management GL Account tab.' ELSE 'Commodity GL Accounts M2M tab.' END)

		INSERT INTO @tblAccount(intAccountId, strAccountNo, ysnHasError, strErrorMessage)
		VALUES (NULL, NULL, 1, @ErrMsg)
		RETURN
	END
	IF (ISNULL(@intCommodityId, 0) = 0) RETURN

	SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId

	--Get the account code for Primary
	DECLARE @strPrimaryAccountCode NVARCHAR(20) = ''	
	SELECT @strPrimaryAccountCode = acct.[Primary Account]
	FROM vyuGLAccountView acct
	WHERE acct.intAccountId = @intAccountId


	--Get the account code for Location
	DECLARE @strLocationAccountCode NVARCHAR(20) = ''
		, @strLocationName NVARCHAR(50)
	SELECT @strLocationAccountCode = acctSgmt.strCode
		, @strLocationName = compLoc.strLocationName
	FROM tblSMCompanyLocation compLoc
	LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON compLoc.intProfitCenter = acctSgmt.intAccountSegmentId
	WHERE intCompanyLocationId = @intLocationId

	IF (ISNULL(@strLocationAccountCode, '') = '')
	BEGIN
		SET @ErrMsg = 'Invalid Location on GL Accounts tab of Company Location ' + @strLocationName + '.'
		INSERT INTO @tblAccount(intAccountId, strAccountNo, ysnHasError, strErrorMessage)
		VALUES (NULL, NULL, 1, @ErrMsg)
		RETURN
	END

	--If LOB is setup on GL Account Structure. intStructureType 5 is equal to Line of Bussiness on default data
	IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType = 5)
	BEGIN

		--Check if there is LOB setup for commodity
		IF NOT EXISTS (SELECT TOP 1 * FROM tblICCommodity com INNER JOIN tblSMLineOfBusiness lob ON com.intLineOfBusinessId = lob.intLineOfBusinessId WHERE intCommodityId = @intCommodityId)
		BEGIN
			SET @ErrMsg = 'Segment is missing on  Line of Business setup for commodity: ' + @strCommodityCode
			INSERT INTO @tblAccount(intAccountId, strAccountNo, ysnHasError, strErrorMessage)
			VALUES (NULL, NULL, 1, @ErrMsg)
			RETURN
		END

		--Get the account code for LOB
		DECLARE @strLOBAccountCode NVARCHAR(20) = ''
		SELECT @strLOBAccountCode = acctSgmt.strCode
		FROM tblICCommodity com
		INNER JOIN tblSMLineOfBusiness lob ON com.intLineOfBusinessId = lob.intLineOfBusinessId
		LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON lob.intSegmentCodeId = acctSgmt.intAccountSegmentId
		WHERE intCommodityId = @intCommodityId

		IF ISNULL(@strLOBAccountCode, '') = ''
		BEGIN
			SET @ErrMsg = 'Segment is missing on  Line of Business setup for commodity: ' + @strCommodityCode
			INSERT INTO @tblAccount(intAccountId, strAccountNo, ysnHasError, strErrorMessage)
			VALUES (NULL, NULL, 1, @ErrMsg)
			RETURN
		END

		--Build the account number with LOB
		IF ISNULL(@strPrimaryAccountCode, '') <> '' AND ISNULL(@strLocationAccountCode, '') <> '' AND ISNULL(@strLOBAccountCode, '') <> '' 
		BEGIN
			SET @strFinalAccountId =  @strPrimaryAccountCode + '-' + @strLocationAccountCode + '-' + @strLOBAccountCode
		END
	END 
	ELSE
	BEGIN
		--Build the account number without LOB
		IF ISNULL(@strPrimaryAccountCode, '') <> '' AND ISNULL(@strLocationAccountCode, '') <> ''
		BEGIN
			SET @strFinalAccountId =  @strPrimaryAccountCode +'-'+ @strLocationAccountCode
		END
	END

	--Check if GL Account Number exists. If not throw an error.
	SELECT TOP 1 @intFinalAccountId = intAccountId FROM tblGLAccount WHERE strAccountId = ISNULL(@strFinalAccountId, '')

	IF (ISNULL(@intFinalAccountId, 0) = 0)
	BEGIN
		SET @ErrMsg = 'GL Account Number ' + @strFinalAccountId + ' does not exist.'
		INSERT INTO @tblAccount(intAccountId, strAccountNo, ysnHasError, strErrorMessage)
		VALUES (NULL, NULL, 1, @ErrMsg)
		RETURN
	END

	INSERT INTO @tblAccount(intAccountId, strAccountNo, ysnHasError, strErrorMessage)
	VALUES (@intFinalAccountId, @strFinalAccountId, 0, NULL)

	RETURN
END