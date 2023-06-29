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

	IF @strMessageType = 'PBBS'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Doc No</th>
							<th>&nbsp;PBBS ID</th>
							<th>&nbsp;Blend Code</th>
							<th>&nbsp;PDF File Name</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM tblIPPBBSError t WITH (NOLOCK)
				WHERE t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
					'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.intDocNo), '') + '</td>' +
					'<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.intPBBSID), '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strBlendCode, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strPDFFileName, '') + '</td>' +
					'<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' +
				'</tr>'
			FROM tblIPPBBSError t WITH (NOLOCK)
			WHERE t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPPBBSError t
			WHERE t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Production Order'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Order No</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPBendDemandError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strItem, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPBendDemandError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPBendDemandError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Inventory Adjustment'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Type</th>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Storage Location</th>
							<th>&nbsp;Notes</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPInventoryAdjustmentError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + CASE 
						WHEN t.intTransactionTypeId in (8,-8,0)
							THEN 'Stock Consumption'
						WHEN t.intTransactionTypeId = 10
							THEN 'Stock Adjustment'
						WHEN t.intTransactionTypeId = 12
							THEN 'Stock Transfer'
						WHEN t.intTransactionTypeId = 16
							THEN 'Status Adjustment'
						WHEN t.intTransactionTypeId = 18
							THEN 'Expiry Date Adjustment'
						WHEN t.intTransactionTypeId = 20
							THEN 'Stock Movement'
						ELSE ''
						END + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageLocation, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strNotes, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPInventoryAdjustmentError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPInventoryAdjustmentError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Recipe'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Recipe Name</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Location</th>
							<th>&nbsp;Valid From</th>
							<th>&nbsp;Valid To</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblMFRecipeStage t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
				AND intStatusId = 2 --1--Processed/2--Failed
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strRecipeName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,t.strValidFrom,106) , '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,t.strValidTo,106), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblMFRecipeStage t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
				AND intStatusId = 2 --1--Processed/2--Failed

			UPDATE t
			SET ysnMailSent = 1
			FROM tblMFRecipeStage t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
				AND intStatusId = 2 --1--Processed/2--Failed
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
