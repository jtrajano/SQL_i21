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
		SET @strComments = '<p>1. Data Related Issues:</p>'

		SET @strHeader = '<table class="GeneratedTable"><tr>
						<th>&nbsp;Wrong Contract Header Id</th>
						<th>&nbsp;Wrong Contract Detail Id</th>
						<th>&nbsp;Wrong Contract Number</th>
						<th>&nbsp;Wrong Contract Seq</th>
						<th>&nbsp;Wrong Transaction Id</th>
						<th>&nbsp;Correct Contract Header Id</th>
						<th>&nbsp;Correct Contract Detail Id</th>
						<th>&nbsp;Correct Contract Number</th>
						<th>&nbsp;Correct Contract Seq</th>
						<th>&nbsp;Correct Transaction Id</th>
					</tr>'

		SELECT @strDetail = ''

		declare
			@strNameSpace nvarchar(100) = 'ContractManagement.view.Contract'
			,@intScreenId int
			;

		select top 1 @intScreenId = intScreenId from tblSMScreen where strNamespace = @strNameSpace

		select @strDetail = @strDetail + '<tr>' +
			'<td>&nbsp;' + ISNULL(LTRIM(intWrongContractHeaderId), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intWrongContractDetailId), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strWrongContractNumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intWrongContractSeq), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intWrongTransactionId), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intCorrectContractHeaderId), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intCorrectContractDetailId), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(strCorrectContractNumber, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intCorrectContractSeq), '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(LTRIM(intCorrectTransactionId), '') + '</td>' + 
		'</tr>'
			from (
			select distinct
				intWrongContractHeaderId = h.intContractHeaderId
				,intWrongContractDetailId = d.intContractDetailId
				,strWrongContractNumber = h.strContractNumber
				,intWrongContractSeq = d.intContractSeq
				,intWrongTransactionId = t.intTransactionId
				,intCorrectContractHeaderId = correctContract.intContractHeaderId
				,intCorrectContractDetailId = correctContract.intContractDetailId
				,strCorrectContractNumber = correctContract.strContractNumber
				,intCorrectContractSeq = correctContract.intContractSeq
				,intCorrectTransactionId = correctContract.intTransactionId
			from tblSMActivity a
			join tblSMTransaction t on t.intTransactionId = a.intTransactionId and t.intScreenId = @intScreenId
			join tblCTContractHeader h on h.intContractHeaderId = t.intRecordId
			join tblCTContractDetail d on d.intContractHeaderId = h.intContractHeaderId
			cross apply (
				select ch.intContractHeaderId,cd.intContractDetailId,ch.strContractNumber,cd.intContractSeq,tx.intTransactionId
				from tblCTContractDetail cd
				join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
				join tblSMTransaction tx on tx.intRecordId = ch.intContractHeaderId and tx.intScreenId = @intScreenId
				where cd.intContractDetailId = t.intRecordId
			) correctContract
			where a.strType = 'Email' and a.strSubject like 'Contract%Instruction%'
			and a.strSubject not like 'Contract - ' + h.strContractNumber +'-' + convert(nvarchar(50),d.intContractSeq) +  '%'
		) tmp

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
