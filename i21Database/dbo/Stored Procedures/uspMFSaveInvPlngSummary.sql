CREATE PROCEDURE uspMFSaveInvPlngSummary (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strErrMsg NVARCHAR(MAX)
		,@idoc INT
		,@intTransactionCount INT
		,@strInvPlngReportMasterID NVARCHAR(MAX)
		,@intTableConcurrencyId INT
		,@intConcurrencyId INT
		,@intInvPlngSummaryId INT
		,@strDetails NVARCHAR(MAX)
		,@intUserId int
	DECLARE @tblIPAuditLog TABLE (
		strColumnName NVARCHAR(50)
		,strColumnDescription NVARCHAR(200)
		,strOldValue NVARCHAR(MAX)
		,strNewValue NVARCHAR(MAX)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intInvPlngSummaryId = intInvPlngSummaryId
		,@strInvPlngReportMasterID = strInvPlngReportMasterID
		,@intConcurrencyId = intConcurrencyId
		,@intUserId=intCreatedUserId
	FROM OPENXML(@idoc, 'root/InvPlngSummary', 2) WITH (
			intInvPlngSummaryId INT
			,strInvPlngReportMasterID NVARCHAR(MAX)
			,intConcurrencyId INT
			,intCreatedUserId int
			)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @intInvPlngSummaryId = 0
	BEGIN
		INSERT INTO tblMFInvPlngSummary (
			strPlanName
			,dtmDate
			,intUnitMeasureId
			,intBookId
			,intSubBookId
			,strComment
			,intCreatedUserId
			,intLastModifiedUserId
			,intConcurrencyId
			)
		SELECT strPlanName
			,GETDATE()
			,intUnitMeasureId
			,intBookId
			,intSubBookId
			,strComment
			,intCreatedUserId
			,intLastModifiedUserId
			,1
		FROM OPENXML(@idoc, 'root/InvPlngSummary', 2) WITH (
				strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intUnitMeasureId INT
				,intBookId INT
				,intSubBookId INT
				,strComment NVARCHAR(MAX)
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)

		SELECT @intInvPlngSummaryId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SELECT @intTableConcurrencyId = intConcurrencyId
		FROM tblMFInvPlngSummary
		WHERE intInvPlngSummaryId = @intInvPlngSummaryId

		IF @intTableConcurrencyId <> @intConcurrencyId
		BEGIN
			RAISERROR (
					'Demand summary data is already modified by other user. Please refresh.'
					,16
					,1
					,'WITH NOWAIT'
					)
		END

		UPDATE InvPlngSummary
		SET strPlanName = x.strPlanName
			,intUnitMeasureId = x.intUnitMeasureId
			,intBookId = x.intBookId
			,intSubBookId = x.intSubBookId
			,strComment = x.strComment
			,intLastModifiedUserId = x.intLastModifiedUserId
			,intConcurrencyId = (InvPlngSummary.intConcurrencyId + 1)
		FROM OPENXML(@idoc, 'root/InvPlngSummary', 2) WITH (
				intInvPlngSummaryId INT
				,strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intUnitMeasureId INT
				,intBookId INT
				,intSubBookId INT
				,strComment NVARCHAR(MAX)
				,intLastModifiedUserId INT
				) x
		JOIN tblMFInvPlngSummary InvPlngSummary ON x.intInvPlngSummaryId = InvPlngSummary.intInvPlngSummaryId
		WHERE InvPlngSummary.intInvPlngSummaryId = @intInvPlngSummaryId
	END

	DELETE
	FROM tblMFInvPlngSummaryBatch
	WHERE intInvPlngSummaryId = @intInvPlngSummaryId

	INSERT INTO tblMFInvPlngSummaryBatch (
		intInvPlngSummaryId
		,intInvPlngReportMasterID
		)
	SELECT @intInvPlngSummaryId
		,Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')

	INSERT INTO @tblIPAuditLog
	SELECT Distinct (
			SELECT TOP 1 PSD.strValue
			FROM tblMFInvPlngSummaryDetail PSD
			WHERE PSD.intInvPlngSummaryId = @intInvPlngSummaryId
				AND intAttributeId = 1
				AND PSD.strFieldName = x.N
			)
		,B.strBook + IsNULL(' - ' + SB.strSubBook, '') + ' - ' + I.strItemNo + IsNULL(' - [ ' + MI.strItemNo +' ] ', '') + ' - ' + Replace(Replace(RA.strAttributeName, '<a>+ ', ''), '</a>', '') 
		,SD.strValue
		,x.V
	FROM OPENXML(@idoc, 'root/InvPlngSummaryDetails/SD', 2) WITH (
			A INT
			,I INT
			,N NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,V NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,MI INT
			,B INT
			,SB INT
			) x
	JOIN tblMFInvPlngSummaryDetail SD ON x.A = SD.intAttributeId
		AND x.I = SD.intItemId
		AND x.N = SD.strFieldName
		AND IsNULL(x.MI,0) = IsNULL(SD.intMainItemId,0)
		AND x.B = SD.intBookId
		--AND IsNUll(x.intSubBookId,0) = IsNULL(SD.intSubBookId,0)
	JOIN tblICItem I ON I.intItemId = x.I
	LEFT JOIN tblICItem MI ON MI.intItemId = x.MI
	JOIN tblCTBook B ON B.intBookId = x.B
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = x.SB
	JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = x.A
	WHERE x.V <> SD.strValue
		AND SD.intInvPlngSummaryId = @intInvPlngSummaryId
		And SD.intAttributeId in (4,9)

	DELETE
	FROM tblMFInvPlngSummaryDetail
	WHERE intInvPlngSummaryId = @intInvPlngSummaryId

	INSERT INTO tblMFInvPlngSummaryDetail (
		intAttributeId
		,intItemId
		,strFieldName
		,strValue
		,intMainItemId
		,intBookId
		,intSubBookId
		,intInvPlngSummaryId
		)
	SELECT A
		,I
		,N
		,V
		,MI
		,B
		,SB
		,@intInvPlngSummaryId
	FROM OPENXML(@idoc, 'root/InvPlngSummaryDetails/SD', 2) WITH (
			A INT
			,I INT
			,N NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,V NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,MI INT
			,B INT
			,SB INT
			)

	IF EXISTS (
			SELECT *
			FROM @tblIPAuditLog
			)
	BEGIN
		SELECT @strDetails = ''

		SELECT @strDetails += '{"change":"' + strColumnName + '","iconCls":"small-gear","from":"' + Ltrim(isNULL(strOldValue, '')) + '","to":"' + Ltrim(IsNULL(strNewValue, '')) + '","leaf":true,"changeDescription":"' + strColumnDescription + '"},'
		FROM @tblIPAuditLog 
		WHERE IsNULL(strOldValue, '') <> IsNULL(strNewValue, '')
	END

	IF (LEN(@strDetails) > 1)
	BEGIN
		SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

		EXEC uspSMAuditLog @keyValue = @intInvPlngSummaryId
			,@screenName = 'Manufacturing.view.DemandSummaryView'
			,@entityId = @intUserId
			,@actionType = 'Updated'
			,@actionIcon = 'small-tree-modified'
			,@details = @strDetails
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc

	SELECT @intInvPlngSummaryId AS intInvPlngSummaryId
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
