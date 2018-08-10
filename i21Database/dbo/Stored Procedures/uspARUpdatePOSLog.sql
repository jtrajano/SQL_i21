CREATE PROCEDURE [dbo].[uspARUpdatePOSLog]
	@intPOSLogId AS INT,
	@intCompanyLocationPOSDrawerId AS INT = NULL,
	@intEntityUserId AS INT = NULL,
	@intCompanyLocationId AS INT = NULL,
	@intStoreId AS INT = NULL,
	@intPOSLogOriginId AS INT = NULL,
	@intBankDepositId AS INT = NULL,
	@dblOpeningBalance AS DECIMAL(18,6) = NULL,
	@dblEndingBalance AS DECIMAL(18,6) = NULL,
	@dtmLogin AS DATETIME = NULL,
	@dtmLogout AS DATETIME = NULL,
	@ysnLoggedIn AS BIT = NULL
AS
BEGIN
	
	BEGIN TRANSACTION
		UPDATE tblARPOSLog
		SET
				intEntityUserId				= ISNULL(@intEntityUserId, intEntityUserId),
				intCompanyLocationPOSDrawerId	= ISNULL(@intCompanyLocationPOSDrawerId, intCompanyLocationPOSDrawerId),
				intCompanyLocationId			= ISNULL(@intCompanyLocationId, intCompanyLocationId),
				intStoreId						= ISNULL(@intStoreId, intStoreId),
				intPOSLogOriginId				= ISNULL(@intPOSLogOriginId, intPOSLogOriginId),
				intBankDepositId				= ISNULL(@intBankDepositId, intBankDepositId),
				dblOpeningBalance				= ISNULL(@dblOpeningBalance, dblOpeningBalance),
				dblEndingBalance				= ISNULL(@dblEndingBalance, dblEndingBalance),
				dtmLogin						= ISNULL(@dtmLogin, dtmLogin),
				dtmLogout						= ISNULL(@dtmLogout, dtmLogout),
				ysnLoggedIn					= ISNULL(@ysnLoggedIn, ysnLoggedIn)
		WHERE intPOSLogId = @intPOSLogId

	IF(ISNULL(@intPOSLogId,0) != 0)
		COMMIT
	ELSE
		ROLLBACK

END