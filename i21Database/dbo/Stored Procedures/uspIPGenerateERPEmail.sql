CREATE PROCEDURE uspIPGenerateERPEmail @strMessageType NVARCHAR(50) = ''
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

	IF @strMessageType = 'Item'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Location</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Description</th>
							<th>&nbsp;Commodity</th>
							<th>&nbsp;Category</th>
							<th>&nbsp;Action</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF @strStatus = 'Success'
		BEGIN
			IF EXISTS (
				SELECT 1
				FROM tblIPItemArchive WITH (NOLOCK)
				WHERE intActionId = 1
					AND ysnMailSent = 0
				)
			BEGIN
				SELECT @strDetail = @strDetail + '<tr>' + 
					   '<td>&nbsp;' + ISNULL(CL.strLocationName, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strDescription, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCommodity, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCategoryCode, '') + '</td>' + 
					   '<td>&nbsp;' + CASE WHEN t.intActionId=1 THEN 'Create' WHEN t.intActionId=4 THEN 'Delete' Else 'Update' End + '</td>' + 
					   '<td>&nbsp;' + ISNULL('Success', '') + '</td>' + 
				'</tr>'
				FROM tblIPItemArchive t WITH (NOLOCK)
				LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLotOrigin = t.strCompanyLocation
				WHERE t.intActionId = 1
					AND t.ysnMailSent = 0
			
				UPDATE tblIPItemArchive
				SET ysnMailSent = 1
				WHERE intActionId = 1
					AND ysnMailSent = 0
			END
		END
		ELSE IF @strStatus = 'Failure'
		BEGIN
			IF EXISTS (
				SELECT 1
				FROM tblIPItemError WITH (NOLOCK)
				WHERE ysnMailSent = 0
				)
			BEGIN
				SELECT @strDetail = @strDetail + '<tr>' + 
					   '<td>&nbsp;' + ISNULL(CL.strLocationName, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strDescription, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCommodity, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCategoryCode, '') + '</td>' + 
					   '<td>&nbsp;' + CASE WHEN t.intActionId=1 THEN 'Create' WHEN t.intActionId=4 THEN 'Delete' Else 'Update' End + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
				'</tr>'
				FROM tblIPItemError t WITH (NOLOCK)
				LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLotOrigin = t.strCompanyLocation
				WHERE t.ysnMailSent = 0

				UPDATE tblIPItemError
				SET ysnMailSent = 1
				WHERE ysnMailSent = 0
			END
		END
	END

	IF @strMessageType = 'Customer'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Location</th>
							<th>&nbsp;Contract No</th>
							<th>&nbsp;Customer</th>
						</tr>'

		SELECT @strDetail = @strDetail + '<tr>' + 
				'<td>&nbsp;' + ISNULL(CL.strLocationName, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(CH.strContractNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(E.strName, '') + '</td>' + 
		'</tr>'
		FROM tblCTContractHeader CH WITH (NOLOCK)
		JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractHeaderId = CH.intContractHeaderId
			AND CH.intContractTypeId = 2
		JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = CD.intCompanyLocationId
		JOIN tblARCustomer C WITH (NOLOCK) ON C.intEntityId = CH.intEntityId
		JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = C.intEntityId
			AND ISNULL(C.strLinkCustomerNumber, '') = ''
	END

	-- Outgoing ERP Feeds

	IF @strMessageType = 'PO'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Contract No</th>
							<th>&nbsp;Sequence No</th>
							<th>&nbsp;ERP PO No</th>
							<th>&nbsp;Location</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 1
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CF.strContractNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, CF.intContractSeq), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strERPPONumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 1
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0

			UPDATE CF
			SET ysnMailSent = 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 1
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'CO'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Contract No</th>
							<th>&nbsp;Sequence No</th>
							<th>&nbsp;ERP CO No</th>
							<th>&nbsp;Location</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 2
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CF.strContractNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, CF.intContractSeq), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strERPPONumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 2
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0

			UPDATE CF
			SET ysnMailSent = 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 2
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Commitment Pricing'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Pricing No</th>
							<th>&nbsp;Posted</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblMFCommitmentPricingStage t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CP.strPricingNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.ysnPost), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblMFCommitmentPricingStage t WITH (NOLOCK)
			JOIN tblMFCommitmentPricing CP WITH (NOLOCK) ON CP.intCommitmentPricingId = t.intCommitmentPricingId
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblMFCommitmentPricingStage t
			JOIN tblMFCommitmentPricing CP WITH (NOLOCK) ON CP.intCommitmentPricingId = t.intCommitmentPricingId
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Goods Receipt'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Receipt No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPInvReceiptFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strReceiptNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPInvReceiptFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPInvReceiptFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Lot Item Change'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Old Item No</th>
							<th>&nbsp;New Item No</th>
							<th>&nbsp;Mother Lot No</th>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPLotItemChangeFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strOldItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strNewItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMotherLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPLotItemChangeFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPLotItemChangeFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Lot Merge'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Storage Unit</th>
							<th>&nbsp;Dest. Lot No</th>
							<th>&nbsp;Dest. Storage Unit</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPLotMergeFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageUnit, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strDestinationLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strDestinationStorageUnit, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPLotMergeFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPLotMergeFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Lot Property'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Mother Lot No</th>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Storage Unit</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPLotPropertyFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strMotherLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageUnit, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPLotPropertyFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPLotPropertyFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Lot Split'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Storage Unit</th>
							<th>&nbsp;Split Lot No</th>
							<th>&nbsp;Split Storage Unit</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPLotSplitFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageUnit, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strSplitLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strSplitStorageUnit, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPLotSplitFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPLotSplitFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Transfer Order'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Transfer No</th>
							<th>&nbsp;ERP Transfer No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPInvTransferFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strTransferNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPTransferOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPInvTransferFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPInvTransferFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Voucher'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Voucher No</th>
							<th>&nbsp;ERP Voucher No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblAPBillPreStage t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(B.strBillId, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.strERPVoucherNo), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblAPBillPreStage t WITH (NOLOCK)
			JOIN tblAPBill B WITH (NOLOCK) ON B.intBillId = t.intBillId
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblAPBillPreStage t
			JOIN tblAPBill B WITH (NOLOCK) ON B.intBillId = t.intBillId
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Inventory Adjust Ack'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Storage Unit</th>
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
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageUnit, '') + '</td>' + 
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

	IF @strMessageType = 'Production'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Work Order No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblMFProductionPreStage t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(W.strWorkOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblMFProductionPreStage t WITH (NOLOCK)
			JOIN tblMFWorkOrder W WITH (NOLOCK) ON W.intWorkOrderId = t.intWorkOrderId
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblMFProductionPreStage t
			JOIN tblMFWorkOrder W WITH (NOLOCK) ON W.intWorkOrderId = t.intWorkOrderId
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Production Order'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Work Order No</th>
							<th>&nbsp;ERP Order No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblMFWorkOrderPreStage t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(W.strWorkOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(W.strERPOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblMFWorkOrderPreStage t WITH (NOLOCK)
			JOIN tblMFWorkOrder W WITH (NOLOCK) ON W.intWorkOrderId = t.intWorkOrderId
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblMFWorkOrderPreStage t
			JOIN tblMFWorkOrder W WITH (NOLOCK) ON W.intWorkOrderId = t.intWorkOrderId
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Service Order'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Work Order No</th>
							<th>&nbsp;ERP Order No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblMFWorkOrderPreStage t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(W.strWorkOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(W.strERPOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblMFWorkOrderPreStage t WITH (NOLOCK)
			JOIN tblMFWorkOrder W WITH (NOLOCK) ON W.intWorkOrderId = t.intWorkOrderId
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblMFWorkOrderPreStage t
			JOIN tblMFWorkOrder W WITH (NOLOCK) ON W.intWorkOrderId = t.intWorkOrderId
			WHERE t.intStatusId IN (1, 3)
				AND ISNULL(t.ysnMailSent, 0) = 0
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
