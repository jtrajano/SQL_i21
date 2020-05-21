CREATE PROCEDURE uspIPGenerateSAPFeedFailureEmailMessage_CA @strMessageType NVARCHAR(50)
AS
BEGIN TRY
	DECLARE @strStyle NVARCHAR(MAX)
		,@strHtml NVARCHAR(MAX)
		,@strHeader NVARCHAR(MAX)
		,@strDetail NVARCHAR(MAX) = ''
		,@strMessage NVARCHAR(MAX)
		,@intDuration INT = 30

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

					<table class="GeneratedTable">
						<tbody>
							@header
							@detail
						</tbody>
					</table>

					</body>
				</html>'

	IF @strMessageType = 'Shipment'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Cargoo Reference</th>
						<th>&nbsp;Order Reference</th>
						<th>&nbsp;Load No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Status</th>
						<th>&nbsp;Message</th>
					</tr>'

		SELECT @strDetail = @strDetail + 
		'<tr>
			<td>&nbsp;' + CASE 
				WHEN UPPER(strTransactionType) = 'SHIPPINGINSTRUCTION'
					THEN 'LSI'
				WHEN UPPER(strTransactionType) = 'SHIPMENT'
					THEN 'LS'
				WHEN UPPER(strTransactionType) = 'LSI_CANCEL'
					THEN 'LSI Cancel'
				ELSE ISNULL(strTransactionType, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strCustomerReference, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strLoadNumber, '') + '</td>' + 
			'<td>&nbsp;' + CASE 
				WHEN UPPER(strAction) = 'ADDED'
					THEN 'Create'
				WHEN UPPER(strAction) = 'MODIFIED'
					THEN 'Update'
				WHEN UPPER(strAction) = 'CANCEL'
					THEN 'Cancel'
				ELSE ISNULL(strAction, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strImportStatus, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
		</tr>'
		FROM tblIPLoadError t WITH (NOLOCK)
		WHERE ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')

		UPDATE tblIPLoadError
		SET ysnMailSent = 1
		WHERE ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')

		SELECT @strDetail = @strDetail + 
		'<tr>
			<td>&nbsp;' + CASE 
				WHEN UPPER(strTransactionType) = 'SHIPPINGINSTRUCTION'
					THEN 'LSI'
				WHEN UPPER(strTransactionType) = 'SHIPMENT'
					THEN 'LS'
				WHEN UPPER(strTransactionType) = 'LSI_CANCEL'
					THEN 'LSI Cancel'
				ELSE ISNULL(strTransactionType, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strCustomerReference, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strLoadNumber, '') + '</td>' + 
			'<td>&nbsp;' + CASE 
				WHEN UPPER(strAction) = 'ADDED'
					THEN 'Create'
				WHEN UPPER(strAction) = 'MODIFIED'
					THEN 'Update'
				WHEN UPPER(strAction) = 'CANCEL'
					THEN 'Cancel'
				ELSE ISNULL(strAction, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strImportStatus, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strInternalErrorMessage, '') + '</td>
		</tr>'
		FROM tblIPLoadArchive t WITH (NOLOCK)
		WHERE ISNULL(ysnInternalMailSent, 0) = 0
			AND ISNULL(strInternalErrorMessage, '') NOT IN ('')

		UPDATE tblIPLoadArchive
		SET ysnInternalMailSent = 1
		WHERE ISNULL(ysnInternalMailSent, 0) = 0
			AND ISNULL(strInternalErrorMessage, '') NOT IN ('')
	END

	IF @strMessageType = 'LSI'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Cargoo Reference</th>
						<th>&nbsp;Order Reference</th>
						<th>&nbsp;Load No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Status</th>
						<th>&nbsp;Message</th>
					</tr>'

		SELECT @strDetail = @strDetail + 
		'<tr>
			<td>&nbsp;' + 'LSI' + '</td>' + 
			'<td>&nbsp;' + ISNULL(strCustomerReference, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strLoadNumber, '') + '</td>' + 
			'<td>&nbsp;' + CASE 
				WHEN UPPER(strAction) = 'ADDED'
					THEN 'Create'
				WHEN UPPER(strAction) = 'MODIFIED'
					THEN 'Update'
				WHEN UPPER(strAction) = 'CANCEL'
					THEN 'Cancel'
				ELSE ISNULL(strAction, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strImportStatus, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
		</tr>'
		FROM tblIPLoadError t WITH (NOLOCK)
		WHERE strTransactionType = 'ShippingInstruction'
			AND ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')

		UPDATE tblIPLoadError
		SET ysnMailSent = 1
		WHERE strTransactionType = 'ShippingInstruction'
			AND ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')
	END

	IF @strMessageType = 'LS'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Cargoo Reference</th>
						<th>&nbsp;Order Reference</th>
						<th>&nbsp;Load No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Status</th>
						<th>&nbsp;Message</th>
					</tr>'

		SELECT @strDetail = @strDetail + 
		'<tr>
			<td>&nbsp;' + 'LS' + '</td>' + 
			'<td>&nbsp;' + ISNULL(strCustomerReference, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strLoadNumber, '') + '</td>' + 
			'<td>&nbsp;' + CASE 
				WHEN UPPER(strAction) = 'ADDED'
					THEN 'Create'
				WHEN UPPER(strAction) = 'MODIFIED'
					THEN 'Update'
				WHEN UPPER(strAction) = 'CANCEL'
					THEN 'Cancel'
				ELSE ISNULL(strAction, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strImportStatus, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
		</tr>'
		FROM tblIPLoadError t WITH (NOLOCK)
		WHERE strTransactionType = 'Shipment'
			AND ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')

		UPDATE tblIPLoadError
		SET ysnMailSent = 1
		WHERE strTransactionType = 'Shipment'
			AND ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')
	END

	IF @strMessageType = 'LSI_Cancel'
	BEGIN
		SET @strHeader = '<tr>
						<th>&nbsp;Transaction</th>
						<th>&nbsp;Cargoo Reference</th>
						<th>&nbsp;Order Reference</th>
						<th>&nbsp;Load No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Status</th>
						<th>&nbsp;Message</th>
					</tr>'

		SELECT @strDetail = @strDetail + 
		'<tr>
			<td>&nbsp;' + 'LSI Cancel' + '</td>' + 
			'<td>&nbsp;' + ISNULL(strCustomerReference, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strERPPONumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strLoadNumber, '') + '</td>' + 
			'<td>&nbsp;' + CASE 
				WHEN UPPER(strAction) = 'ADDED'
					THEN 'Create'
				WHEN UPPER(strAction) = 'MODIFIED'
					THEN 'Update'
				WHEN UPPER(strAction) = 'CANCEL'
					THEN 'Cancel'
				ELSE ISNULL(strAction, '')
				END + '</td>' + 
			'<td>&nbsp;' + ISNULL(strImportStatus, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strErrorMessage, '') + '</td>
		</tr>'
		FROM tblIPLoadError t WITH (NOLOCK)
		WHERE strTransactionType = 'LSI_Cancel'
			AND ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')

		UPDATE tblIPLoadError
		SET ysnMailSent = 1
		WHERE strTransactionType = 'LSI_Cancel'
			AND ISNULL(ysnMailSent, 0) = 0
			AND ISNULL(strErrorMessage, '') NOT IN ('','Success')
	END

	SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
	SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strDetail, '') = ''
		SET @strMessage = ''

	SELECT @strMessage AS strMessage
END TRY

BEGIN CATCH
	SELECT '' AS strMessage
END CATCH
