CREATE PROCEDURE uspIPGenerateImportFailureEmailMessage @strMessageType NVARCHAR(50)
	,@strStatus NVARCHAR(50) = ''
AS
BEGIN TRY
	DECLARE @strStyle NVARCHAR(MAX)
		,@strHtml NVARCHAR(MAX)
		,@strHeader NVARCHAR(MAX)
		,@strDetail NVARCHAR(MAX) = ''
		,@strMessage NVARCHAR(MAX)
		,@ysnError BIT = 1

	IF @strStatus = 'Success'
		SELECT @ysnError = 0 -- Processed
	ELSE IF @strStatus = 'Failure'
		SELECT @ysnError = 1 -- Failed

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
						<th>&nbsp;Sample No.</th>
						<th>&nbsp;Lot Number</th>
						<th>&nbsp;Import Date</th>
						<th>&nbsp;Message</th>
					</tr>'

		SELECT @strDetail = @strDetail + 
		'<tr>' + 
			'<td>&nbsp;' + ISNULL(strSampleNumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strLotNumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmCreated, 120), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strErrorMsg, '') + '</td>' + 
		'</tr>'
		FROM tblQMLotSampleImportArchive WITH (NOLOCK)
		WHERE ysnError = @ysnError
			AND ysnMailSent = 0

		UPDATE tblQMLotSampleImportArchive
		SET ysnMailSent = 1
		WHERE ysnError = @ysnError
			AND ysnMailSent = 0
	END

	SET @strHtml = REPLACE(@strHtml, '@header', ISNULL(@strHeader, ''))
	SET @strHtml = REPLACE(@strHtml, '@detail', ISNULL(@strDetail, ''))
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strDetail, '') = ''
		SET @strMessage = ''

	SELECT @strMessage AS strMessage
END TRY

BEGIN CATCH
	SELECT '' AS strMessage
END CATCH
