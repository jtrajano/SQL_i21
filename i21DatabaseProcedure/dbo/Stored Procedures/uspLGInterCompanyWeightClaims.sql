CREATE PROCEDURE uspLGInterCompanyWeightClaims
	@intWeightClaimId INT
AS
BEGIN TRY
	DECLARE @intLoadId INT = 16
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @strWeightClaimNo NVARCHAR(100)
	DECLARE @strFromTransactionType NVARCHAR(100)
	DECLARE @intFromTransactionTypeId INT
	DECLARE @strToTransactionType NVARCHAR(100)
	DECLARE @intToTransactionTypeId INT
	DECLARE @intFromCompanyId INT
	DECLARE @intToCompanyId INT
	DECLARE @intToCompanyLocationId INT
	DECLARE @strType NVARCHAR(100)
	DECLARE @strWeightClaimTransactionType NVARCHAR(100)
	DECLARE @strInsert NVARCHAR(20)
	DECLARE @strUpdate NVARCHAR(20)
	DECLARE @intToBookId INT
	DECLARE @intToSubBookId INT

	DECLARE @tblLoadContractWeightClaims TABLE (
		intRecordId INT IDENTITY
		,intLoadId INT
		,strLoadNumber NVARCHAR(100)
		,intLoadDetailId INT
		,intContractDetailId INT
		,intContractHeaderId INT
		)
	
	SELECT @intLoadId = intLoadId,
		   @strWeightClaimNo = strReferenceNumber
	FROM tblLGWeightClaim
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @strLoadNumber = strLoadNumber
		,@strType = CASE LOAD.intPurchaseSale
			WHEN 1
				THEN 'Inbound'
			WHEN 2
				THEN 'Outbound'
			WHEN 3
				THEN 'Drop-Ship'
			END
	FROM tblLGLoad LOAD
	WHERE intLoadId = @intLoadId

	SET @strWeightClaimTransactionType = @strType + ' Weight Claims'
	
	IF EXISTS (
			SELECT 1
			FROM tblSMInterCompanyTransactionConfiguration CTC
			JOIN [tblSMInterCompanyTransactionType] CTTF ON CTC.[intFromTransactionTypeId] = CTTF.intInterCompanyTransactionTypeId
			JOIN [tblSMInterCompanyTransactionType] CTTT ON CTC.[intToTransactionTypeId] = CTTT.intInterCompanyTransactionTypeId
			WHERE CTTF.strTransactionType = @strWeightClaimTransactionType
			)
	BEGIN
		SELECT @strFromTransactionType = FCTT.strTransactionType  -- AS strFromTransactionType
			,@intFromTransactionTypeId = ICTC.intFromTransactionTypeId
			,@strToTransactionType = TCTT.strTransactionType -- AS strToTransactionType
			,@intToTransactionTypeId = ICTC.intToTransactionTypeId
			,@intFromCompanyId = intFromCompanyId
			,@intToCompanyId = intToCompanyId
			,@strInsert = strInsert
			,@strUpdate = strUpdate
			,@intToCompanyLocationId = intCompanyLocationId
			,@intToBookId = intToBookId
		FROM tblSMInterCompanyTransactionConfiguration ICTC
		JOIN tblSMInterCompanyTransactionType FCTT ON FCTT.intInterCompanyTransactionTypeId = ICTC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TCTT ON TCTT.intInterCompanyTransactionTypeId = ICTC.intToTransactionTypeId	
		WHERE FCTT.strTransactionType = @strWeightClaimTransactionType

		IF @strInsert = 'Insert'
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGWeightClaim WHERE intWeightClaimId = @intWeightClaimId)
			BEGIN
			      EXEC uspLGPopulateWeightClaimXML @intWeightClaimId = @intWeightClaimId
												  ,@strToTransactionType = @strToTransactionType
												  ,@intToCompanyId = @intToCompanyId
												  ,@strRowState = 'Added'
												  ,@intToCompanyLocationId = @intToCompanyLocationId 
												  ,@intToBookId = @intToBookId
			END	
		END
	END
	
	IF @strWeightClaimTransactionType = 'Drop-Ship Weight Claims'
	BEGIN
		IF EXISTS (
			SELECT 1
			FROM tblSMInterCompanyTransactionConfiguration CTC
			JOIN [tblSMInterCompanyTransactionType] CTTF ON CTC.[intFromTransactionTypeId] = CTTF.intInterCompanyTransactionTypeId
			JOIN [tblSMInterCompanyTransactionType] CTTT ON CTC.[intToTransactionTypeId] = CTTT.intInterCompanyTransactionTypeId
			WHERE CTTF.strTransactionType = 'Outbound Weight Claims' AND CTTT.strTransactionType = 'Inbound Weight Claims' AND intFromCompanyId = intToCompanyId
			)
		BEGIN
			EXEC uspLGCreateWeightClaims @intWeightClaimId = @intWeightClaimId
		END
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH