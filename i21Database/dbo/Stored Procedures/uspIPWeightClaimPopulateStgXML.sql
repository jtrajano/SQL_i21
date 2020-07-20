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
		,@intCompanyId = intCompanyId
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

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany
	WHERE ysnParent=1

	IF EXISTS (
			SELECT 1
			FROM master.dbo.sysdatabases
			WHERE name = @strDatabaseName
			)
	BEGIN
		SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + 
			'.dbo.tblLGWeightClaimStage (
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
		,intCompanyId = @intCompanyId'

		EXEC sp_executesql @strSQL
			,N'@intWeightClaimId int
		,@strReferenceNumber nvarchar(50)
		,@strWeightClaimXML nvarchar(MAX)
		,@strWeightClaimDetailXML nvarchar(MAX)
		,@strRowState nvarchar(50)
		,@intTransactionId int
		,@intCompanyId int'
			,@intWeightClaimId
			,@strReferenceNumber
			,@strWeightClaimXML
			,@strWeightClaimDetailXML
			,@strRowState
			,@intTransactionId
			,@intCompanyId
	END
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
