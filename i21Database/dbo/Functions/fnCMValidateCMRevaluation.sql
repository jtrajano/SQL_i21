CREATE FUNCTION [dbo].[fnCMValidateCMRevaluation]
(
	@intGLFiscalYearPeriodId	AS INT,
	@strTransactionType			AS NVARCHAR(255),
	@ysnPost					AS BIT = 1
)
RETURNS NVARCHAR(255)
AS
BEGIN
	DECLARE 
		@ysnCMForwardsRevalued BIT,
		@ysnCMInTransitRevalued BIT,
		@ysnCMSwapsRevalued BIT,
		@ysnRevalue_Forward BIT,
		@ysnRevalue_InTransit BIT,
		@ysnRevalue_Swap BIT,
		@strMessage NVARCHAR(255) = NULL

	IF (@strTransactionType IN ('CM', 'CM Forwards', 'CM In-Transit', 'CM Swaps') AND @ysnPost = 1)
	BEGIN
		-- Validate CM transaction type
		-- Make sure all other CM transaction types were revalued (if revaluation was enabled)
		SELECT 
			@ysnCMForwardsRevalued = ysnCMForwardsRevalued, 
			@ysnCMInTransitRevalued = ysnCMInTransitRevalued, 
			@ysnCMSwapsRevalued = ysnCMSwapsRevalued 
		FROM tblGLFiscalYearPeriod 
		WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId

		IF @strTransactionType = 'CM'
		BEGIN
			SELECT TOP 1 
				@ysnRevalue_Forward = ysnRevalue_Forward,
				@ysnRevalue_InTransit = ysnRevalue_InTransit,
				@ysnRevalue_Swap = ysnRevalue_Swap
			FROM tblCMCompanyPreferenceOption

			IF ISNULL(@ysnCMForwardsRevalued, 0) = 0 AND ISNULL(@ysnRevalue_Forward, 0) = 1
				SET @strMessage = '''Forwards'' Transaction Type must be revalued.'
			IF ISNULL(@ysnCMInTransitRevalued, 0) = 0 AND ISNULL(@ysnRevalue_InTransit, 0) = 1
				SET @strMessage = '''In-Transit'' Transaction Type must be revalued.'
			IF ISNULL(@ysnCMSwapsRevalued, 0) = 0 AND ISNULL(@ysnRevalue_Swap, 0) = 1
				SET @strMessage = '''Swaps'' Transaction Type must be revalued.'
		END

		IF (@strTransactionType IN ('CM Forwards', 'CM In-Transit', 'CM Swaps'))
		BEGIN
			IF @strTransactionType = 'CM Forwards' AND ISNULL(@ysnCMForwardsRevalued, 0) = 1
				SET @strMessage = '''Forwards'' Transaction Type already revalued.'
			IF @strTransactionType = 'CM In-Transit' AND ISNULL(@ysnCMInTransitRevalued, 0) = 1
				SET @strMessage = '''In-Transit'' Transaction Type already revalued.'
			IF @strTransactionType = 'CM Swaps' AND ISNULL(@ysnCMSwapsRevalued, 0) = 1
				SET @strMessage = '''Swaps'' Transaction Type already revalued.'
		END
	END

	RETURN @strMessage
END
