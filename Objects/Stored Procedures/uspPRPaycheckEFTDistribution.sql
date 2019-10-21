CREATE PROCEDURE uspPRPaycheckEFTDistribution
	@intPaycheckId AS INT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

	DECLARE @dblAmount NUMERIC(18, 6)
	DECLARE @intEntityEmployeeId AS INT
	DECLARE @intPaycheck INT
	DECLARE @dtmPayDate DATETIME

	--Get necessary variables
	SELECT 
		@dblAmount = dblNetPayTotal
		,@intEntityEmployeeId = intEntityEmployeeId
		,@intPaycheck = intPaycheckId
		,@dtmPayDate = dtmPayDate
	FROM tblPRPaycheck 
	WHERE intPaycheckId = @intPaycheckId

	--Clear Direct Deposit Entry
	DELETE FROM tblPRPaycheckDirectDeposit WHERE intPaycheckId = @intPaycheckId

	--Get EFT Info
	SELECT 
		intOrder
		,intEntityEFTInfoId
		,intBankId
		,strBankName
		,strAccountNumber = [dbo].fnAESDecryptASym(strAccountNumber)
		,strDistributionType
		,dblAmount
	INTO #tmpEFTInfo
	FROM [tblEMEntityEFTInformation]
	WHERE intEntityId = @intEntityEmployeeId
		AND ysnActive = 1
	ORDER BY 
		intOrder ASC

	DECLARE @intEntityEFTInfoId INT
	DECLARE @intPaycheckDirectDepositId INT

	--Loop through each 
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEFTInfo)
	BEGIN

		SELECT TOP 1 @intEntityEFTInfoId = intEntityEFTInfoId FROM #tmpEFTInfo ORDER BY intOrder ASC

		--Insert Allocation Amount to Paycheck Direct Deposit
		INSERT INTO tblPRPaycheckDirectDeposit (
			intPaycheckId
			,dtmDate
			,intBankId
			,strAccountNumber
			,strDistributionType
			,dblAmount
			,dblAllocation)
		SELECT
			@intPaycheckId
			,@dtmPayDate
			,intBankId
			,strAccountNumber
			,strDistributionType
			,dblAmount
			,dblAllocation = CASE 
								WHEN (strDistributionType = 'Fixed Amount')
									THEN CASE WHEN (dblAmount < @dblAmount) THEN dblAmount ELSE @dblAmount END
								WHEN (strDistributionType = 'Percent')
									THEN @dblAmount * (dblAmount / 100)
								ELSE
									@dblAmount
								END
		FROM #tmpEFTInfo 
		WHERE intEntityEFTInfoId = @intEntityEFTInfoId

		SELECT @intPaycheckDirectDepositId = @@IDENTITY

		--Reduce the Amount by the Allocated value
		SELECT @dblAmount  = @dblAmount - dblAllocation 
		FROM tblPRPaycheckDirectDeposit WHERE intPaycheckDirectDepositId = @intPaycheckDirectDepositId

		--Loop control
		DELETE FROM #tmpEFTInfo WHERE intEntityEFTInfoId = @intEntityEFTInfoId

	END

END