CREATE PROCEDURE uspIPGenerateSAPFeedFailureEmailMessage_ST @strMessageType NVARCHAR(50),@intStatusId int=2
AS
BEGIN TRY
	DECLARE @strStyle NVARCHAR(MAX)
		,@strHtml NVARCHAR(MAX)
		,@strHeader NVARCHAR(MAX)
		,@strDetail NVARCHAR(MAX) = ''
		,@strMessage NVARCHAR(MAX)
		,@intDuration INT = 30
	DECLARE @intLotErrorCount INT
		,@intLotSuccessCount INT
		,@strSummaryDetail NVARCHAR(MAX) = ''

	SELECT @intDuration = ISNULL(strValue, 30)
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'GLOBAL'
		AND strTag = 'FEED_READ_DURATION'

	SET @strStyle = '<style type="text/css" scoped>
					table.GeneratedTable {
						width:80%;
						background-color:#FFFFFF;
						border-collapse:collapse;border-width:1px;
						border-color:#000000;
						border-style:solid;
						color:#000000;
					}

					table.GeneratedTable td {
						border-width:1px;
						border-color:#000000;
						border-style:solid;
						padding:3px;
					}

					table.GeneratedTable th {
						border-width:1px;
						border-color:#000000;
						border-style:solid;
						background-color:yellow;
						padding:3px;
					}

					table.GeneratedTable thead {
						background-color:#FFFFFF;
					}
					</style>'
	SET @strHtml = '<html>
					<body>
						@summary

					<table class="GeneratedTable">
						<tbody>
							@header
							@detail
						</tbody>
					</table>

					</body>
				</html>'

	IF @strMessageType = 'Sample'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Sample No.</th>
						<th>&nbsp;PO Number</th>
						<th>&nbsp;PO Item No.</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Message</th>
					</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPSampleError WITH (NOLOCK)
			WHERE ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + 
			'<tr>
				<td>&nbsp;' + 'Sample' + '</td>' + 
				'<td>&nbsp;' + ISNULL(strSampleNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strERPItemNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strTransactionType, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
			</tr>'
			FROM tblIPSampleError t WITH (NOLOCK)
			WHERE ysnMailSent = 0

			UPDATE tblIPSampleError
			SET ysnMailSent = 1
			WHERE ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Receipt'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Receipt No.</th>
						<th>&nbsp;BL Number</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Message</th>
					</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPInvReceiptError WITH (NOLOCK)
			WHERE ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + 
			'<tr>
				<td>&nbsp;' + 'Receipt' + '</td>' + 
				'<td>&nbsp;' + ISNULL(strReceiptNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strBLNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strTransactionType, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
			</tr>'
			FROM tblIPInvReceiptError t WITH (NOLOCK)
			WHERE ysnMailSent = 0

			UPDATE tblIPInvReceiptError
			SET ysnMailSent = 1
			WHERE ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Stock'
	BEGIN
		SELECT @intLotErrorCount = 0
			,@intLotSuccessCount = 0

		SELECT @intLotErrorCount = COUNT(1)
		FROM tblIPLotError WITH (NOLOCK)
		WHERE ysnMailSent = 0

		SELECT @intLotSuccessCount = COUNT(1)
		FROM tblIPLotArchive WITH (NOLOCK)
		WHERE ysnMailSent = 0

		IF @intLotErrorCount > 0
			OR @intLotSuccessCount > 0
		BEGIN
			SET @strSummaryDetail = '<p><b>
										Total Lots: ' + CONVERT(VARCHAR, (@intLotSuccessCount + @intLotErrorCount)) + '</br>
										Processed Lots: ' + CONVERT(VARCHAR, @intLotSuccessCount) + '</br>
										Failed Lots: ' + CONVERT(VARCHAR, @intLotErrorCount) + '</b></p>'
			
			UPDATE tblIPLotArchive
			SET ysnMailSent = 1
			WHERE ysnMailSent = 0
		END

		IF EXISTS (
			SELECT 1
			FROM tblIPLotError WITH (NOLOCK)
			WHERE ysnMailSent = 0
			)
		BEGIN
			SET @strHeader = '<tr>
				<th>&nbsp;Transaction</th>
				<th>&nbsp;Lot No.</th>
				<th>&nbsp;Item No.</th>
				<th>&nbsp;Storage Unit</th>
				<th>&nbsp;Book</th>
				<th>&nbsp;Sub Book</th>
				<th>&nbsp;Message</th>
			</tr>'

			SELECT @strDetail = @strDetail + 
			'<tr>
				<td>&nbsp;' + 'Stock' + '</td>' + 
				'<td>&nbsp;' + ISNULL(strLotNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strItemNo, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strStorageLocationName, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strBook, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strSubBook, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
			</tr>'
			FROM tblIPLotError t WITH (NOLOCK)
			WHERE ysnMailSent = 0

			UPDATE tblIPLotError
			SET ysnMailSent = 1
			WHERE ysnMailSent = 0
		END
	END

	IF @strMessageType = 'LS Status'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Contract No.</th>
						<th>&nbsp;Seq No.</th>
						<th>&nbsp;BL Number</th>
						<th>&nbsp;Status</th>
						<th>&nbsp;ETA</th>
						<th>&nbsp;Message</th>
					</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPShipmentStatusError WITH (NOLOCK)
			WHERE ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + 
			'<tr>
				<td>&nbsp;' + 'LS Status' + '</td>' + 
				'<td>&nbsp;' + ISNULL(strContractNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(CONVERT(VARCHAR, intContractSeq), '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strBLNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strStatus, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmETA, 106), '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
			</tr>'
			FROM tblIPShipmentStatusError t WITH (NOLOCK)
			WHERE ysnMailSent = 0

			UPDATE tblIPShipmentStatusError
			SET ysnMailSent = 1
			WHERE ysnMailSent = 0
		END
	END

IF @strMessageType ='Recipe'
BEGIN
	
	SET @strHeader = '<tr>
						<th>&nbsp;Recipe Name</th>
						<th>&nbsp;Item No</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF EXISTS (
		SELECT *
		FROM tblMFRecipeStage   WITH (NOLOCK)
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, strRecipeName), '') + '</td>' + '<td>&nbsp;' + ISNULL(strItemNo, '') + '</td>' + '<td>&nbsp;' + ISNULL(strTransactionType, '') + '</td>' + '<td>&nbsp;' + ISNULL(strMessage, '') + '</td> 
	</tr>'
		FROM tblMFRecipeStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL

		UPDATE tblMFRecipeStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL
	END
END

IF @strMessageType ='Recipe Item'
BEGIN
	
	SET @strHeader = '<tr>
						<th>&nbsp;Recipe Name</th>
						<th>&nbsp;Recipe Header Item No</th>
						<th>&nbsp;Item No</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF EXISTS (
		SELECT *
		FROM tblMFRecipeItemStage   WITH (NOLOCK)
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, strRecipeName), '') + '</td>' + '<td>&nbsp;' + ISNULL(strRecipeHeaderItemNo, '') + '</td>' + '<td>&nbsp;' + ISNULL(strRecipeItemNo, '') + '</td>' + '<td>&nbsp;' + ISNULL(strMessage, '') + '</td> 
	</tr>'
		FROM tblMFRecipeItemStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL

		UPDATE tblMFRecipeItemStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL
	END
END
IF @strMessageType ='PO'
BEGIN
	
	SET @strHeader = '<tr>
						<th>&nbsp;Contract Number</th>
						<th>&nbsp;Contract Seq Number</th>
						<th>&nbsp;ERP PO Number</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF EXISTS (
		SELECT *
		FROM dbo.tblCTContractFeed   WITH (NOLOCK)
		WHERE strMessage is not null
			AND ysnMailSent =0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, strContractNumber), '') + '</td>' + '<td>&nbsp;' + ISNULL(Ltrim(intContractSeq), '') + '</td>' + '<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + '<td>&nbsp;' + ISNULL(strMessage, '') + '</td> 
	</tr>'
		FROM dbo.tblCTContractFeed WITH (NOLOCK)
		WHERE strMessage is not null
			AND ysnMailSent =0

		UPDATE tblCTContractFeed
		SET ysnMailSent = 1
		WHERE strMessage is not null
			AND ysnMailSent =0
	END
END

	SET @strHtml = REPLACE(@strHtml, '@header', ISNULL(@strHeader, ''))
	SET @strHtml = REPLACE(@strHtml, '@detail', ISNULL(@strDetail, ''))
	SET @strHtml = REPLACE(@strHtml, '@summary', ISNULL(@strSummaryDetail, ''))
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strDetail, '') = ''
		SET @strMessage = ''
	
	IF ISNULL(@strSummaryDetail, '') <> ''
		SET @strMessage = @strStyle + @strHtml

	SELECT @strMessage AS strMessage
END TRY

BEGIN CATCH
	SELECT '' AS strMessage
END CATCH
