CREATE PROCEDURE uspIPGenerateEmail_EK @strMessageType NVARCHAR(50) = ''
	,@strStatus NVARCHAR(50) = ''
AS
BEGIN TRY
	DECLARE @strStyle NVARCHAR(MAX)
		,@strHtml NVARCHAR(MAX)
		,@strHeader NVARCHAR(MAX)
		,@strDetail NVARCHAR(MAX) = ''
		,@strMessage NVARCHAR(MAX)

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
							border-color:#d0d0d0;
							border-style:solid;
							padding:3px;
							background-color: #F1F4F8;
							color: #0f0f0f;
							font-size: 12px;
							font-family: Verdana, Geneva, Tahoma, sans-serif;
						}

						table.GeneratedTable th {
							border-width:1px;
							border-color:#d0d0d0;
							border-style:solid;
							background-color:#3572b0;
							color:white;
							padding:3px;
							font-size: 12px;
							font-family: Verdana, Geneva, Tahoma, sans-serif;
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

	IF @strMessageType = 'Contract Header'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Doc No</th>
							<th>&nbsp;Contract No</th>
							<th>&nbsp;Location</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM tblIPContractHeaderError t WITH (NOLOCK)
				WHERE t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.intDocNo), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strContractNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strLocation, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPContractHeaderError t WITH (NOLOCK)
			WHERE t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPContractHeaderError t
			WHERE t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Goods Receipt'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Doc No</th>
							<th>&nbsp;Receipt No.</th>
							<th>&nbsp;BL Number</th>
							<th>&nbsp;Location</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM tblIPInvReceiptError t WITH (NOLOCK)
				WHERE t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
					'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.intTrxSequenceNo), '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strERPReceiptNo, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strBLNumber, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strLocationName, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' +
				'</tr>'
			FROM tblIPInvReceiptError t WITH (NOLOCK)
			WHERE t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPInvReceiptError t
			WHERE t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Vendor'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Doc No</th>
							<th>&nbsp;Name</th>
							<th>&nbsp;Account No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM tblIPEntityError t WITH (NOLOCK)
				WHERE t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
					'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.intTrxSequenceNo), '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strName, '') + '</td>' + 
					'<td>&nbsp;' + ISNULL(t.strAccountNo, '') + '</td>' + 
					'<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
				'</tr>'
			FROM tblIPEntityError t WITH (NOLOCK)
			WHERE t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPEntityError t
			WHERE t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Stock'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Doc No</th>
							<th>&nbsp;Batch Id</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Location</th>
							<th>&nbsp;Storage Location</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM tblIPLotError t WITH (NOLOCK)
				WHERE t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
					'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.intTrxSequenceNo), '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strLotNumber, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strLocationName, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strSubLocationName, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' +
				'</tr>'
			FROM tblIPLotError t WITH (NOLOCK)
			WHERE t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPLotError t
			WHERE t.ysnMailSent = 0
		END
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
