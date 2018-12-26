CREATE PROCEDURE [dbo].[uspARPOSLogEndOfDay]
	@intPOSEndOfDayId AS INT,
	@intEntityId AS INT,
	@dblNewEndingBalance AS DECIMAL(18,6)
AS
	IF ISNULL(@intPOSEndOfDayId, 0) <> 0
	BEGIN
		DECLARE 
			    @intCashOverAccountId	INT 			= NULL
			  , @intUndepositedFundsId	INT 			= NULL
			  , @intCurrencyId			INT				= (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
			  , @dblCashOverShort		NUMERIC(18, 6) 	= 0
			  , @dtmDateNow				DATETIME 		= GETDATE()
			  , @ZeroDecimal			DECIMAL(18,6)	= 0.000000
			  , @strEODNumber			NVARCHAR(200)	= NULL
			  , @strErrorMessage		NVARCHAR(200)	= NULL
			  , @strCompanyLocationName	NVARCHAR(200)	= NULL
			

		IF EXISTS(SELECT TOP 1 intPOSEndOfDayId FROM tblARPOSLog WHERE intPOSEndOfDayId = @intPOSEndOfDayId)
		BEGIN
			SELECT
				 @intCashOverAccountId	 = LOC.intCashOverShort
				,@intUndepositedFundsId	 = LOC.intUndepositedFundsId
				,@strCompanyLocationName = LOC.strLocationName
				,@strEODNumber			 = EOD.strEODNo
				,@dblCashOverShort		 = @dblNewEndingBalance - ((EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0)) - ABS(ISNULL(dblCashReturn,0)))
			FROM tblARPOSEndOfDay EOD
			INNER JOIN (
				SELECT
					 intCompanyLocationPOSDrawerId
					,intCompanyLocationId
				FROM tblSMCompanyLocationPOSDrawer
			) DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
			INNER JOIN(
				SELECT
					 intCompanyLocationId
					,strLocationName
					,intUndepositedFundsId
					,intCashOverShort
				FROM tblSMCompanyLocation
			) LOC ON DRAWER.intCompanyLocationId = LOC.intCompanyLocationId
			WHERE EOD.intPOSEndOfDayId = @intPOSEndOfDayId
														

			--VALIDATE GL ACCOUNTS
			IF (ISNULL(@intCashOverAccountId, 0) = 0 AND ISNULL(@intUndepositedFundsId, 0) = 0)
			BEGIN
				SET @strErrorMessage = '' + ISNULL(@strCompanyLocationName, '') + ' does not have GL setup for Cash Over/Short and Undeposited Funds. Please set it up in Company Location > GL Accounts.'
				RAISERROR(@strErrorMessage, 16, 1)
				RETURN;
			END
			ELSE IF(ISNULL(@intCashOverAccountId, 0) = 0)
			BEGIN
				SET @strErrorMessage = '' + ISNULL(@strCompanyLocationName, '') + ' does not have GL setup for Cash Over/Short. Please set it up in Company Location > GL Accounts.'
				RAISERROR(@strErrorMessage, 16, 1)
				RETURN;
			END
			ELSE IF(ISNULL(@intUndepositedFundsId, 0) = 0)
			BEGIN
				SET @strErrorMessage =  '' + ISNULL(@strCompanyLocationName, '') + ' does not have GL setup for Undeposited Funds. Please set it up in Company Location > GL Accounts.'
				RAISERROR(@strErrorMessage, 16, 1)
				RETURN;
			END
			
			BEGIN TRANSACTION
			IF(ISNULL(@dblCashOverShort,@ZeroDecimal) <> @ZeroDecimal)
			BEGIN

				--Update accounts of EOD before passing to tblGLDetail
				UPDATE tblARPOSEndOfDay
					SET
						 intCashOverShortId = @intCashOverAccountId
						,intUndepositedFundsId = @intUndepositedFundsId
				WHERE intPOSEndOfDayId = @intPOSEndOfDayId

				EXEC uspARPOSPostEOD
						@intPOSEndOfDayId		= @intPOSEndOfDayId
					   ,@intCashOverShortId		= @intCashOverAccountId
					   ,@intUndepositedFundsId	= @intUndepositedFundsId
					   ,@intCurrencyId			= @intCurrencyId
					   ,@intEntityUserId		= @intEntityId
					   ,@dblCashOverShort		= @dblCashOverShort
					   ,@strEODNumber			= @strEODNumber
					   ,@strMessage				= @strErrorMessage OUT
			END

			IF(@strErrorMessage IS NULL)
			BEGIN
				COMMIT TRANSACTION

				--CLOSE DRAWER 
				UPDATE	tblARPOSEndOfDay
					SET
						 intEntityId = @intEntityId
						,dblFinalEndingBalance = @dblNewEndingBalance
						,dtmClose = @dtmDateNow
						,ysnClosed = 1
				WHERE intPOSEndOfDayId = @intPOSEndOfDayId
				
				--UPDATE POSLOG
				UPDATE tblARPOSLog
				SET dtmLogout 			= @dtmDateNow
				  , ysnLoggedIn 		= 0
				WHERE intPOSEndOfDayId = @intPOSEndOfDayId

			END --END IF SUCCESS IN POSTING EOD 
			ELSE --FAIL POSTING EOD
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR(@strErrorMessage, 16, 1)
				RETURN;
			END


		END --END IF EXIST


	END