CREATE FUNCTION [dbo].[fnRKGetOTCAllowedBankAccounts]
(
	  @intLocationId INT
	, @strInstrumentType NVARCHAR(100)
	, @intCurrencyId INT = NULL
	, @intBankId INT = NULL
)
RETURNS @returntable TABLE
(
	  intBankAccountId INT
	, strBankAccountNo NVARCHAR(MAX)
	, intBankId INT
	, intCurrencyId INT
	, strNickname NVARCHAR(100)
)
AS
BEGIN
	DECLARE @intLocationAccountSegmentId INT = NULL
		, @ysnAllowDiffLocation_Forward BIT = 0
		, @ysnAllowDiffLocation_Swap BIT = 0

	SELECT	@ysnAllowDiffLocation_Forward = ysnAllowBetweenLocations_Forward
		  , @ysnAllowDiffLocation_Swap = ysnAllowBetweenLocations_Swap
	FROM tblCMCompanyPreferenceOption

	-- IF Config Allow Between Locations = Unchecked, Limit the Bank Accounts based on Location Cash Account of Location Selected.
	IF (
		((@strInstrumentType = 'Spot' OR @strInstrumentType = 'Forward') AND @ysnAllowDiffLocation_Forward = 0)
		OR
		(@strInstrumentType = 'Swap' AND @ysnAllowDiffLocation_Swap = 0)
	)
	BEGIN
		SELECT	@intLocationAccountSegmentId = intProfitCenter 
		FROM	tblSMCompanyLocation
		WHERE intCompanyLocationId = @intLocationId

		-- IF @intLocationAccountSegmentId is NULL, No bank accounts retrieved.
		INSERT INTO @returntable (
			  intBankAccountId 
			, strBankAccountNo 
			, intBankId
			, intCurrencyId 
			, strNickname
		)
		SELECT	bankAcct.intBankAccountId
			, bankAcct.strBankAccountNo
			, bankAcct.intBankId
			, bankAcct.intCurrencyId
			, bankAcct.strNickname
		FROM	vyuCMBankAccount bankAcct
		JOIN	tblGLAccount glAcct
			ON glAcct.intAccountId = bankAcct.intGLAccountId
			AND glAcct.intLocationSegmentId = @intLocationAccountSegmentId
		WHERE bankAcct.intCurrencyId = ISNULL(@intCurrencyId, bankAcct.intCurrencyId)
		AND bankAcct.intBankId = ISNULL(@intBankId, bankAcct.intBankId)
	END
	ELSE
	BEGIN
		INSERT INTO @returntable (
			  intBankAccountId 
			, strBankAccountNo 
			, intBankId
			, intCurrencyId 
			, strNickname
		)
		SELECT	bankAcct.intBankAccountId
			, bankAcct.strBankAccountNo
			, bankAcct.intBankId
			, bankAcct.intCurrencyId
			, bankAcct.strNickname
		FROM	vyuCMBankAccount bankAcct
		WHERE bankAcct.intCurrencyId = ISNULL(@intCurrencyId, bankAcct.intCurrencyId)
		AND bankAcct.intBankId = ISNULL(@intBankId, bankAcct.intBankId)
	END
RETURN
END
