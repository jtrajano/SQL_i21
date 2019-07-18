CREATE PROCEDURE [dbo].[uspSCScanAndSaveSealNumber]
	@intTicketId INT,
	@strSealNumber VARCHAR(150),
	@intUserId INT,
	@dtmScanDate DATETIME,
	@ysnScan BIT = 1,
	@ysnThrowError BIT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
BEGIN
	DECLARE @intTicketSealNumberId INT
	DECLARE @tblSCTicketSealNumber AS TABLE (intTicketId INT,intSealNumberId INT,intTruckDriverReferenceId INT,intUserId INT,intConcurrencyId INT)
	DECLARE @intTruckReferenceId AS INT
	DECLARE @strErrorMessage VARCHAR(150) = 'Seal Number '+ @strSealNumber + ' already exist.'

	SELECT @intTruckReferenceId = TDR.intTruckDriverReferenceId FROM vyuSCTicketView vSC
	INNER JOIN tblSCTruckDriverReference TDR
		ON TDR.strData = vSC.strTruckName and TDR.strRecordType <> 'D'
	WHERE intTicketId = @intTicketId

	IF NOT EXISTS(SELECT 1 FROM vyuSCTicketView WHERE intTicketId = @intTicketId)
	BEGIN
		SET @strErrorMessage = 'Invalid Ticket Id'
		IF(@ysnThrowError = 1)
			RAISERROR(@strErrorMessage ,11,1)
		ELSE
		BEGIN
			SELECT @strErrorMessage strMsg, NULL intSealNumberId
			RETURN;
		END
	END

	IF EXISTS(SELECT 1 FROM tblSCSealNumber WHERE strSealNumber = @strSealNumber)
	BEGIN
		SET @strErrorMessage = 'Seal Number '+ @strSealNumber + ' already exist.'
		IF(@ysnThrowError = 1)
			RAISERROR(@strErrorMessage ,11,1)
		ELSE
		BEGIN
			SELECT @strErrorMessage strMsg, NULL intSealNumberId
			RETURN
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM vyuSCTicketView WHERE intTicketId = @intTicketId)
		BEGIN 
			MERGE INTO tblSCSealNumber as SealNumber
			USING
			(
				SELECT @strSealNumber strSealNumber,@dtmScanDate dtmCreateDate, @ysnScan ysnScanned,@intUserId intUserId, 1 as intConcurrencyId
			) SourceSeal
			ON(SealNumber.strSealNumber = SourceSeal.strSealNumber)
			WHEN NOT MATCHED THEN			
			INSERT (strSealNumber,dtmCreateDate,ysnScanned,intUserId,intConcurrencyId)
			VALUES (SourceSeal.strSealNumber,SourceSeal.dtmCreateDate,SourceSeal.ysnScanned,SourceSeal.intUserId,SourceSeal.intConcurrencyId)
			OUTPUT @intTicketId,inserted.intSealNumberId,@intTruckReferenceId intTruckDriverReferenceId,@intUserId,SourceSeal.intConcurrencyId
			INTO @tblSCTicketSealNumber;

			INSERT INTO tblSCTicketSealNumber(intTicketId,intSealNumberId,intTruckDriverReferenceId,intUserId,intConcurrencyId)
			SELECT intTicketId,intSealNumberId,intTruckDriverReferenceId,intUserId,intConcurrencyId FROM @tblSCTicketSealNumber

			SET @intTicketSealNumberId = SCOPE_IDENTITY();

			IF(ISNULL(@intTicketSealNumberId,0) = 0)
				BEGIN
					SELECT 'Error occured adding Seal Number '+ @strSealNumber strMsg,NULL intSealNumberId
				END
			ELSE
				BEGIN
					SELECT 'Success' strMsg,intSealNumberId FROM tblSCTicketSealNumber WHERE intTicketSealNumberId = @intTicketSealNumberId
				END
		END		
	END
END