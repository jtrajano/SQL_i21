CREATE PROCEDURE uspLGPopulateWeightClaimXML
	@intWeightClaimId INT,
	@strToTransactionType NVARCHAR(100),
	@intToCompanyId INT,
	@strRowState NVARCHAR(100),
	@intToCompanyLocationId INT,
	@intToBookId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(100) = NULL
	DECLARE @strWeightClaimNumber NVARCHAR(100) = NULL
	DECLARE @intScopeIdentityId INT = NULL
	DECLARE @strWeightClaimXML NVARCHAR(MAX) = NULL
	DECLARE @strWeightClaimCondition NVARCHAR(1024)
	DECLARE @strWeightClaimDetailXML NVARCHAR(MAX) = NULL
	DECLARE @strWeightClaimDetailCondition NVARCHAR(1024)
	DECLARE @intNewWeightClaimId INT
	DECLARE @intNewWeightClaimDetailId INT
	DECLARE @intLoadId INT

	SELECT @strWeightClaimNumber = strReferenceNumber,
		   @intLoadId = intLoadId
	FROM tblLGWeightClaim
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	---HEADER
	SELECT @strWeightClaimCondition = 'intWeightClaimId = ' + LTRIM(@intWeightClaimId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGWeightClaim'
		,@strWeightClaimCondition
		,@strWeightClaimXML OUTPUT
		,NULL
		,NULL

	-- WEIGHT CLAIM HEADER TABLE
	INSERT INTO tblLGIntrCompWeightClaimsStg (
		intWeightClaimId
		,strWeightClaimNo
		,strWeightClaim
		,strRowState
		)
	SELECT @intWeightClaimId
		,@strWeightClaimNumber
		,@strWeightClaimXML
		,@strRowState

	SET @intScopeIdentityId = SCOPE_IDENTITY()

	
	-- WEIGHT CLAIM DETAILS TABLE
	SELECT @strWeightClaimDetailCondition = 'intWeightClaimId = ' + LTRIM(@intWeightClaimId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGWeightClaimDetail'
		,@strWeightClaimDetailCondition
		,@strWeightClaimDetailXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompWeightClaimsStg
	SET strWeightClaimDetail = ISNULL(strWeightClaimDetail, '') + @strWeightClaimDetailXML
	WHERE intId = @intScopeIdentityId

	UPDATE tblLGIntrCompWeightClaimsStg
	SET strTransactionType = @strToTransactionType,
		intMultiCompanyId = @intToCompanyId,
		intLoadId = @intLoadId,
		intToCompanyLocationId = @intToCompanyLocationId,
		intToBookId = @intToBookId,
		dtmFeedDate = gETdATE()
	WHERE intId = @intScopeIdentityId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
