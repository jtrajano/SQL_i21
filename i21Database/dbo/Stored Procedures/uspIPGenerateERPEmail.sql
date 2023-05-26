﻿CREATE PROCEDURE uspIPGenerateERPEmail @strMessageType NVARCHAR(50) = ''
	,@strStatus NVARCHAR(50) = ''
	,@ysnDaily bit=0
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
						<table class="GeneratedTable"  
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
							<th>&nbsp;Vendor</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 1
			JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = CH.intEntityId
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CF.strContractNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, CF.intContractSeq), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strERPPONumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(E.strName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 1
			JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = CH.intEntityId
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0

			UPDATE CF
			SET ysnMailSent = 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 1
			JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = CH.intEntityId
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
							<th>&nbsp;Customer</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 2
			JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = CH.intEntityId
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CF.strContractNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, CF.intContractSeq), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strERPPONumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(E.strName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CF.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 2
			JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = CH.intEntityId
			WHERE CF.intStatusId IN (1, 3)
				AND CF.ysnMailSent = 0

			UPDATE CF
			SET ysnMailSent = 1
			FROM tblCTContractFeed CF WITH (NOLOCK)
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CH.intContractTypeId = 2
			JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = CH.intEntityId
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
							<th>&nbsp;Receipt Date</th>
							<th>&nbsp;Container No</th>
							<th>&nbsp;Received By</th>
							<th>&nbsp;Message</th>
							<th>&nbsp;i21/ERP</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPInvReceiptFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = (Case When @ysnDaily = 0 then 0 Else t.ysnMailSent End)
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strReceiptNumber, '') + '</td>' + 
				    '<td>&nbsp;' + ISNULL(convert(varchar, t1.dtmReceiptDate, 106), '') + '</td>' + 
				     '<td>&nbsp;' + ISNULL(LC.strContainerNumber, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(E.strName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
				    '<td>&nbsp;' + (Case When t.intStatusId =1 then 'i21' Else 'ERP' End )+ '</td>' + 
			'</tr>'
			FROM tblIPInvReceiptFeed t WITH (NOLOCK)
			JOIN tblICInventoryReceipt  t1 on t.intInventoryReceiptId  =t1.intInventoryReceiptId 
			JOIN tblICInventoryReceiptItem t2 on t2.intInventoryReceiptItemId =t.intInventoryReceiptItemId 
			Left JOIN tblLGLoadContainer LC on LC.intLoadContainerId=t2.intContainerId 
			Left JOIN tblEMEntity E on E.intEntityId =t1.intCreatedByUserId  
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = (Case When @ysnDaily = 0 then 0 Else t.ysnMailSent End)

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
							<th>&nbsp;Transferred By</th>
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
				    '<td>&nbsp;' + ISNULL(E.strName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPTransferOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPInvTransferFeed t WITH (NOLOCK)
			JOIN tblICInventoryTransfer t1 on t.intInventoryTransferId =t1.intInventoryTransferId 
			JOIN tblEMEntity E on E.intEntityId =t1.intTransferredById 
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


	-- Incoming ERP Feeds

	IF @strMessageType = 'Blend Demand'
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

	IF @strMessageType = 'Commitment Pricing Bal Qty'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Pricing No</th>
							<th>&nbsp;Quantity</th>
							<th>&nbsp;ERP Ref No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPCommitmentPricingBalQtyError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strPricingNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.dblBalanceQty), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPRefNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPCommitmentPricingBalQtyError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPCommitmentPricingBalQtyError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Raw Demand Forecast'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Demand Name</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPDemandError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strDemandName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPDemandError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPDemandError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Exchange Rate'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;From Currency</th>
							<th>&nbsp;To Currency</th>
							<th>&nbsp;Rate</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPCurrencyRateError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strFromCurrency, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strToCurrency, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.dblRate), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPCurrencyRateError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPCurrencyRateError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Transfer Goods Receipt'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;ERP Receipt No</th>
							<th>&nbsp;BOL No</th>
							<th>&nbsp;Transfer No</th>
							<th>&nbsp;ERP Transfer No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPInvReceiptError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPReceiptNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strBLNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strTransferOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPTransferOrderNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPInvReceiptError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPInvReceiptError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Inventory Adjustment'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Type</th>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Item No</th>
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
				   '<td>&nbsp;' + CASE 
						WHEN t.intTransactionTypeId = 8
							THEN 'Consumption'
						WHEN t.intTransactionTypeId = 10
							THEN 'Quantity Adj'
						WHEN t.intTransactionTypeId = 20
							THEN 'Lot Move'
						ELSE ''
						END + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
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

	IF @strMessageType = 'Item Standard Price'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Price</th>
							<th>&nbsp;Currency</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPItemPriceError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.dblStandardCost), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strCurrency, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPItemPriceError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPItemPriceError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Payment Status'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Voucher No</th>
							<th>&nbsp;ERP Voucher No</th>
							<th>&nbsp;ERP Journal No</th>
							<th>&nbsp;ERP Payment No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPPaymentStatusError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strVoucherNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPVoucherNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPJournalNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPPaymentReferenceNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPPaymentStatusError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPPaymentStatusError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Recipe'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Recipe Name</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Location</th>
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

	IF @strMessageType = 'Route'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Manufacturing Cell</th>
							<th>&nbsp;Storage Unit</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPItemRouteError t WITH (NOLOCK)
			JOIN tblIPItemRouteDetailError RD WITH (NOLOCK) ON RD.intItemRouteStageId = t.intItemRouteStageId
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(RD.strManufacturingCell, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(RD.strStorageLocation, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPItemRouteError t WITH (NOLOCK)
			JOIN tblIPItemRouteDetailError RD WITH (NOLOCK) ON RD.intItemRouteStageId = t.intItemRouteStageId
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPItemRouteError t WITH (NOLOCK)
			JOIN tblIPItemRouteDetailError RD WITH (NOLOCK) ON RD.intItemRouteStageId = t.intItemRouteStageId
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Stock Feed'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Lot No</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Storage Location</th>
							<th>&nbsp;Storage Unit</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPLotError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strLotNumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strSubLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageLocationName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPLotError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPLotError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Storage Unit'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Storage Location</th>
							<th>&nbsp;Storage Unit</th>
							<th>&nbsp;Storage Unit Type</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPStorageLocationError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageLocation, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageUnit, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strStorageUnitType, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPStorageLocationError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPStorageLocationError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Vendor'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Name</th>
							<th>&nbsp;Account No</th>
							<th>&nbsp;Term</th>
							<th>&nbsp;Currency</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPEntityError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strAccountNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strTerm, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strCurrency, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPEntityError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPEntityError t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
		END
	END

	IF @strMessageType = 'Voucher Feed'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Vendor Name</th>
							<th>&nbsp;Account No</th>
							<th>&nbsp;Invoice No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
			SELECT 1
			FROM tblIPBillStage t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
				AND t.intStatusId = 2
			)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(t.strVendorName, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strVendorAccountNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strInvoiceNo, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblIPBillStage t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
				AND t.intStatusId = 2

			UPDATE t
			SET ysnMailSent = 1
			FROM tblIPBillStage t WITH (NOLOCK)
			WHERE ISNULL(t.ysnMailSent, 0) = 0
				AND t.intStatusId = 2
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
