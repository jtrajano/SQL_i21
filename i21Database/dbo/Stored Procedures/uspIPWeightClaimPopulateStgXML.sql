CREATE PROCEDURE [dbo].[uspIPWeightClaimPopulateStgXML] @intWeightClaimId INT
	,@strRowState NVARCHAR(50)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strObjectName NVARCHAR(50)
		,@strHeaderCondition NVARCHAR(50)
		,@strWeightClaimXML NVARCHAR(MAX)
		,@strWeightClaimDetailXML NVARCHAR(MAX)
		,@intCompanyId INT
		,@intTransactionId INT
		,@intWeightClaimScreenId INT
		,@strReferenceNumber NVARCHAR(100)

	IF @strRowState = 'Delete'
	BEGIN
		INSERT INTO tblLGWeightClaimStage (
			intWeightClaimId
			,strRowState
			)
		SELECT intWeightClaimId = @intWeightClaimId
			,strRowState = @strRowState

		RETURN
	END

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intWeightClaimId = ' + LTRIM(@intWeightClaimId)

	SELECT @strReferenceNumber = strReferenceNumber
	FROM tblLGWeightClaim
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @strObjectName = 'vyuIPGetWeightClaim'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strWeightClaimXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetWeightClaimDetail'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strWeightClaimDetailXML OUTPUT
		,NULL
		,NULL

	SELECT @intWeightClaimScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'Logistics.view.WeightClaims'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intRecordId = @intWeightClaimId
		AND intScreenId = @intWeightClaimScreenId

	INSERT INTO tblLGWeightClaimStage (
		intWeightClaimId
		,strReferenceNumber
		,strWeightClaimXML
		,strWeightClaimDetailXML
		,strRowState
		,intTransactionId
		,intCompanyId
		)
	SELECT intWeightClaimId = @intWeightClaimId
		,strReferenceNumber = @strReferenceNumber
		,strWeightClaimXML = @strWeightClaimXML
		,strWeightClaimDetailXML = @strWeightClaimDetailXML
		,strRowState = @strRowState
		,intTransactionId = @intTransactionId
		,intCompanyId = @intCompanyId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
