CREATE PROCEDURE [dbo].[uspCMGetBankTransferGLRevalueAccount]
(
	@strTransactionId NVARCHAR(50),
	@strModule NVARCHAR(50)
)
AS
BEGIN
	DECLARE 
		@intReceivablesAccountId INT, 
		@intPayablesAccountId INT, 
		@intUnrealizedId INT,
		@intUnrealizedOffsetId INT,
		@intBankTransferTypeId INT, 
		@strErrorMessage NVARCHAR(100)

	DECLARE @tblAccountId TABLE (
		intAccountId INT,
		intUnrealizedId INT,
		intBankTransferTypeId INT,
		strModule NVARCHAR(50),
		strType NVARCHAR(50),
		intOffset BIT,
		intFinalAccountId INT,
		ysnHasLocationSegment BIT NULL,
		ysnHasCompanySegment BIT NULL,
		ysnProcessed BIT
	)

	SELECT TOP 1
		@intReceivablesAccountId = intGLAccountIdTo,
		@intPayablesAccountId = intGLAccountIdFrom,
		@intBankTransferTypeId = intBankTransferTypeId
	FROM tblCMBankTransfer 
	WHERE strTransactionId = @strTransactionId

	SELECT TOP 1
		@intUnrealizedId = CASE 
							WHEN @strModule = 'CM Forwards' THEN intGainOnForwardUnrealizedId 
							WHEN @strModule = 'CM In-Transit' THEN intCashManagementUnrealizedId
							ELSE NULL END,
		@intUnrealizedOffsetId = CASE 
							WHEN @strModule = 'CM Forwards' THEN intGainOnForwardOffsetId
							WHEN @strModule = 'CM In-Transit' THEN intCashManagementOffsetId
							ELSE NULL END
	FROM tblSMMultiCurrency

	IF(@intReceivablesAccountId IS NULL OR @intPayablesAccountId IS NULL)
	BEGIN
		SET @strErrorMessage = 'Unable to find GL Account for Transaction: ' + @strTransactionId
		GOTO _raiserror
	END

	IF(@intUnrealizedId IS NULL OR @intUnrealizedOffsetId IS NULL)
	BEGIN
		SET @strErrorMessage = 'No Unrealized Gain or Loss Account setup in Company Configuration.'
		GOTO _raiserror
	END
	
	IF (@strModule = 'CM Forwards')
		INSERT INTO @tblAccountId
		VALUES  (@intPayablesAccountId,		@intUnrealizedId,		@intBankTransferTypeId, @strModule, 'Payables',		0, NULL, NULL, NULL, 0),
				(@intPayablesAccountId,		@intUnrealizedOffsetId, @intBankTransferTypeId, @strModule, 'Payables',		1, NULL, NULL, NULL, 0),
				(@intReceivablesAccountId,	@intUnrealizedId,		@intBankTransferTypeId, @strModule, 'Receivables',	0, NULL, NULL, NULL, 0),
				(@intReceivablesAccountId,	@intUnrealizedOffsetId, @intBankTransferTypeId, @strModule, 'Receivables',	1, NULL, NULL, NULL, 0)
	ELSE IF (@strModule = 'CM In-Transit')
		INSERT INTO @tblAccountId
		VALUES	(@intReceivablesAccountId,	@intUnrealizedId,		@intBankTransferTypeId, @strModule, 'Receivables',	0, NULL, NULL, NULL, 0),
				(@intReceivablesAccountId,	@intUnrealizedOffsetId, @intBankTransferTypeId, @strModule, 'Receivables',	1, NULL, NULL, NULL, 0)
			
	UPDATE A
	SET
		A.ysnHasLocationSegment = CAST((CASE WHEN LocationSegment.intCount > 0 THEN 1 ELSE 0 END) AS BIT),
		A.ysnHasCompanySegment = CAST((CASE WHEN CompanySegment.intCount > 0 THEN 1 ELSE 0 END) AS BIT)
	FROM @tblAccountId A
	OUTER APPLY (
		SELECT COUNT(1) intCount FROM tblGLAccountSegment Segment
		JOIN tblGLAccountSegmentMapping SegmentMapping
			ON SegmentMapping.intAccountSegmentId = Segment.intAccountSegmentId
		JOIN tblGLAccountStructure Structure
			ON Structure.intAccountStructureId = Segment.intAccountStructureId
		WHERE SegmentMapping.intAccountId = A.intAccountId AND Structure.intStructureType = 3
	) LocationSegment
	OUTER APPLY (
		SELECT COUNT(1) intCount FROM tblGLAccountSegment Segment
		JOIN tblGLAccountSegmentMapping SegmentMapping
			ON SegmentMapping.intAccountSegmentId = Segment.intAccountSegmentId
		JOIN tblGLAccountStructure Structure
			ON Structure.intAccountStructureId = Segment.intAccountStructureId
		WHERE SegmentMapping.intAccountId = A.intAccountId AND Structure.intStructureType = 6
	) CompanySegment

	DECLARE
		@intCurrentAccountId INT, 
		@intCurrentUnrealizedId INT, 
		@intCurrentBankTransferTypeId INT, 
		@intAccountOverridden INT,
		@ysnHasLocationSegment BIT, 
		@ysnHasCompanySegment BIT

	WHILE EXISTS(SELECT TOP 1 1 FROM @tblAccountId WHERE ysnProcessed = 0)
	BEGIN

		SELECT TOP 1 
			@intCurrentAccountId = intAccountId, 
			@intCurrentUnrealizedId = intUnrealizedId,
			@intCurrentBankTransferTypeId = intBankTransferTypeId,
			@ysnHasLocationSegment = ysnHasLocationSegment,
			@ysnHasCompanySegment = ysnHasCompanySegment
		FROM @tblAccountId  WHERE ysnProcessed = 0

		IF(ISNULL(@ysnHasLocationSegment, 0) = 1)
		BEGIN
			BEGIN TRY
				EXEC dbo.uspGLGetOverrideGLAccount @intCurrentAccountId, @intCurrentUnrealizedId, 3, @intBankTransferTypeId, @intAccountOverridden OUTPUT
			END TRY
			BEGIN CATCH
				SELECT  @strErrorMessage = ERROR_MESSAGE();
				GOTO _raiserror
			END CATCH
		END

		IF(ISNULL(@ysnHasCompanySegment, 0) = 1)
		BEGIN
			BEGIN TRY
				IF(@intAccountOverridden IS NULL)
					SET @intAccountOverridden = @intCurrentUnrealizedId

				EXEC dbo.uspGLGetOverrideGLAccount @intCurrentAccountId, @intAccountOverridden, 6, @intBankTransferTypeId, @intAccountOverridden OUTPUT
			END TRY
			BEGIN CATCH
				SELECT  @strErrorMessage = ERROR_MESSAGE();
				GOTO _raiserror
			END CATCH
		END

		IF(@intAccountOverridden IS NULL)
			SET @intAccountOverridden = @intCurrentUnrealizedId

		UPDATE @tblAccountId 
		SET
			intFinalAccountId = @intAccountOverridden,
			ysnProcessed = 1 
		WHERE 
			intAccountId = @intCurrentAccountId 
			AND intUnrealizedId = @intCurrentUnrealizedId
			AND intBankTransferTypeId = @intCurrentBankTransferTypeId

		SET @intAccountOverridden = NULL
	END

	SELECT strModule, strType, intFinalAccountId AccountId, intOffset Offset FROM @tblAccountId GROUP BY strModule, strType, intFinalAccountId, intOffset
	GOTO _end

_raiserror:
	RAISERROR (@strErrorMessage, 16, 1)
	RETURN

_end:

END
