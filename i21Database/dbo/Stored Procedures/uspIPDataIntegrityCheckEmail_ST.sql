CREATE PROCEDURE uspIPDataIntegrityCheckEmail_ST @strMessageType NVARCHAR(50)
AS
BEGIN TRY
	DECLARE @strStyle NVARCHAR(MAX)
		,@strHtml NVARCHAR(MAX)
		,@strHeader NVARCHAR(MAX)
		,@strDetail NVARCHAR(MAX) = ''
		,@strFinalDetail NVARCHAR(MAX) = ''
		,@strComments NVARCHAR(MAX) = ''
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
						
						@detail

					</body>
				</html>'

	IF @strMessageType = 'LG'
	BEGIN
		SET @strComments = '<p>1. Check if the total shipping instruction quantity (except cancelled) against a Purchase contract & Sales contract sequence is matching the dblShippingInstructionQty in the ContractDetail table (both purchase and sales side if it is dropship, only purchase side if it is Inbound)</p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Contract Seq</th>
						<th>&nbsp;Contract SI Qty</th>
						<th>&nbsp;Load SI Qty</th>
					</tr>'

		/* 
		1. Check if the total shipping instruction quantity (except cancelled) against a Purchase contract & Sales contract sequence 
			is matching the dblShippingInstructionQty in the ContractDetail table (both purchase and sales side if it is dropship, only purchase side if it is Inbound)
		*/
		SELECT @strDetail = ''

		SELECT @strDetail = @strDetail + '<tr>' +
			'<td>&nbsp;' + ISNULL(CH.strContractNumber + '/' + CAST(CD.intContractSeq AS NVARCHAR(10)), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(CD.dblShippingInstructionQty), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM((CASE 
				WHEN (CH.intContractTypeId = 2)
					THEN SLSI.dblShippingInstructionQty
				ELSE PLSI.dblShippingInstructionQty
				END)), '') + '</td>' + 
		'</tr>'
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		OUTER APPLY 
			(SELECT dblShippingInstructionQty = SUM(LD.dblQuantity)
				FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
				WHERE LD.intPContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 2 AND ISNULL(L.ysnCancelled, 0) = 0) PLSI
		OUTER APPLY 
			(SELECT dblShippingInstructionQty = SUM(LD.dblQuantity)
				FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
				WHERE LD.intSContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 2 AND ISNULL(L.ysnCancelled, 0) = 0) SLSI
		WHERE ISNULL(CD.dblShippingInstructionQty, 0) <> CASE WHEN (CH.intContractTypeId = 2) THEN ISNULL(SLSI.dblShippingInstructionQty, 0) ELSE ISNULL(PLSI.dblShippingInstructionQty, 0) END

		IF ISNULL(@strDetail, '') <> ''
			SELECT @strFinalDetail = @strFinalDetail + @strComments + @strHeader + @strDetail + '</table><br/>'

		SET @strComments = '<p>2. Check if the total scheduled quantity of Open LS (not posted) is matching with dblScheduledQty in Contract Detail table(both purchase and sales side if it is dropship, only purchase side if it is Inbound)</p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Contract Seq</th>
						<th>&nbsp;Contract Sched Qty</th>
						<th>&nbsp;Load Sched Qty</th>
					</tr>'

		/*
		2. Check if the total scheduled quantity of Open LS (not posted) is matching with dblScheduledQty in Contract Detail table(both purchase and sales side if it is dropship, 
			only purchase side if it is Inbound)
		*/
		SELECT @strDetail = ''

		SELECT @strDetail = @strDetail + '<tr>' +
			'<td>&nbsp;' + ISNULL(CH.strContractNumber + '/' + CAST(CD.intContractSeq AS NVARCHAR(10)), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(CD.dblScheduleQty), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM((CASE 
				WHEN (CH.intContractTypeId = 2)
					THEN SLS.dblScheduleQty
				ELSE PLS.dblScheduleQty
				END)), '') + '</td>' + 
		'</tr>'
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		OUTER APPLY 
			(SELECT dblScheduleQty = SUM(LD.dblQuantity)
				FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
				WHERE LD.intPContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 1 AND ISNULL(L.ysnCancelled, 0) = 0 
				AND ((L.intPurchaseSale = 3 AND ISNULL(L.ysnPosted, 0) = 0) 
				AND L.intShipmentStatus <> 4)) PLS
		OUTER APPLY 
			(SELECT dblScheduleQty = SUM(LD.dblQuantity)
				FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
				WHERE LD.intSContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 1 AND ISNULL(L.ysnCancelled, 0) = 0 
				AND L.intShipmentStatus <> 11) SLS
		WHERE ISNULL(CD.dblScheduleQty, 0) <> CASE WHEN (CH.intContractTypeId = 2) THEN ISNULL(SLS.dblScheduleQty, 0) ELSE ISNULL(PLS.dblScheduleQty, 0) END

		IF ISNULL(@strDetail, '') <> ''
			SELECT @strFinalDetail = @strFinalDetail + @strComments + @strHeader + @strDetail + '</table><br/>'

		SET @strComments = '<p>3. Check if the total LS posted quantity is adjusted correctly comparing the dblScheduledQty and Balance Qty of the Contract Detail table (both purchase and sales side if it is dropship, only purchase side if it is Inbound)</p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Contract Seq</th>
						<th>&nbsp;Contract Qty</th>
						<th>&nbsp;Contract Balance</th>
						<th>&nbsp;Contract Posted Qty</th>
						<th>&nbsp;Load Posted Qty</th>
					</tr>'

		/*
		3. Check if the total LS posted quantity is adjusted correctly comparing the dblScheduledQty and Balance Qty of the Contract Detail table (both purchase and sales side if it is dropship, 
			only purchase side if it is Inbound)
		*/
		SELECT @strDetail = ''

		SELECT @strDetail = @strDetail + '<tr>' +
			'<td>&nbsp;' + ISNULL(CH.strContractNumber + '/' + CAST(CD.intContractSeq AS NVARCHAR(10)), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(CD.dblQuantity), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(CD.dblBalance), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM((CD.dblQuantity - CD.dblBalance)), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM((CASE 
				WHEN (CH.intContractTypeId = 2)
					THEN SLS.dblPostedQty
				ELSE PLS.dblPostedQty
				END)), '') + '</td>' + 
		'</tr>'
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		OUTER APPLY 
			(SELECT dblPostedQty = SUM(LD.dblQuantity) 
				FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
				WHERE LD.intPContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 1 AND ISNULL(L.ysnCancelled, 0) = 0 
				AND ISNULL(L.ysnPosted, 0) = 1 AND (L.intPurchaseSale = 3 OR L.intShipmentStatus = 4)
				) PLS
		OUTER APPLY 
			(SELECT dblPostedQty = SUM(LD.dblQuantity)
				FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
				WHERE LD.intSContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 1 AND ISNULL(L.ysnCancelled, 0) = 0 
				AND ISNULL(L.ysnPosted, 0) = 1 AND L.intShipmentStatus = 11
				) SLS
		WHERE ISNULL((CD.dblQuantity - CD.dblBalance), 0) <> CASE WHEN (CH.intContractTypeId = 2) THEN ISNULL(SLS.dblPostedQty, 0) ELSE ISNULL(PLS.dblPostedQty, 0) END

		IF ISNULL(@strDetail, '') <> ''
			SELECT @strFinalDetail = @strFinalDetail + @strComments + @strHeader + @strDetail + '</table><br/>'
	END

	IF @strMessageType = 'CT'
	BEGIN
		SET @strComments = '<p></p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Contract</th>
					</tr>'

		SELECT @strDetail = ''

		SELECT @strDetail = NULL

		IF ISNULL(@strDetail, '') <> ''
			SELECT @strFinalDetail = @strFinalDetail + @strComments + @strHeader + @strDetail + '</table><br/>'
	END

	IF @strMessageType = 'FRM'
	BEGIN
		SET @strComments = '<p></p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Contract</th>
					</tr>'

		SELECT @strDetail = ''

		SELECT @strDetail = NULL

		IF ISNULL(@strDetail, '') <> ''
			SELECT @strFinalDetail = @strFinalDetail + @strComments + @strHeader + @strDetail + '</table><br/>'
	END

	IF @strMessageType = 'IN'
	BEGIN
		SET @strComments = '<p></p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Contract</th>
					</tr>'

		SELECT @strDetail = ''

		SELECT @strDetail = NULL

		IF ISNULL(@strDetail, '') <> ''
			SELECT @strFinalDetail = @strFinalDetail + @strComments + @strHeader + @strDetail + '</table><br/>'
	END

	SET @strHtml = REPLACE(@strHtml, '@detail', ISNULL(@strFinalDetail, ''))
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strFinalDetail, '') = ''
		SET @strMessage = ''

	SELECT @strMessage AS strMessage
END TRY

BEGIN CATCH
	SELECT '' AS strMessage
END CATCH
