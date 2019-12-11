CREATE PROCEDURE [dbo].[uspCTFeedNotSentEmailMessage]

AS
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

	BEGIN
		SET @strHeader = '<tr>  
		  <th>&nbsp;Contract No</th>  
		  <th>&nbsp;Sequence No</th>
		  <th>&nbsp;Record Id</th>  
		  <th>&nbsp;Feed Status</th>  
		 </tr>'

		SELECT @strDetail = @strDetail + '<tr>  
		   <td>&nbsp;' + ISNULL(TR.strTransactionNo, '') + '</td>'
		 + '<td>&nbsp;' + '' + '</td>'
		 + '<td>&nbsp;' + ISNULL(LTRIM(TR.intRecordId), '') + '</td>'
		 + '<td>&nbsp;' + ' ' + '</td>
	 </tr>'
		FROM tblSMTransaction TR WITH (NOLOCK)
		JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = TR.intRecordId
			AND TR.intScreenId = 11
			AND ISNULL(TR.ysnOnceApproved, 0) = 1
			AND TR.strTransactionNo NOT LIKE 'CP%'
			AND TR.intTransactionId <> 58191
		JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractHeaderId = CH.intContractHeaderId
			AND CD.intContractStatusId <> 2
		LEFT JOIN tblCTContractFeed FD WITH (NOLOCK) ON FD.intContractHeaderId = CH.intContractHeaderId
		WHERE FD.intContractFeedId IS NULL

		Select @strDetail=@strDetail + 
		'<tr>
			   <td>&nbsp;' + ISNULL(CF.strContractNumber,'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,CF.intContractSeq),'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(LTRIM(CF.intContractHeaderId), '') + '</td>'
			+ '<td>&nbsp;' + ISNULL(CF.strFeedStatus,'') + '</td>
		</tr>'
		FROM tblCTContractFeed CF WITH (NOLOCK)
		WHERE ISNULL(CF.strFeedStatus, '') = 'Awt Ack'
			AND CF.strRowState <> 'Delete'
			AND GETDATE() > DATEADD(MI, 15, CF.dtmFeedCreated)
		
		-- After clicing, feed not sent for the original and newly added sequences
		SELECT @strDetail=@strDetail + 
		'<tr>
			   <td>&nbsp;' + ISNULL(CH.strContractNumber,'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,CD.intContractSeq),'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(LTRIM(CD.intContractHeaderId), '') + '</td>'
			+ '<td>&nbsp;' + 'Slicing Issue' + '</td>
		</tr>'
		FROM tblCTContractDetail CD WITH (NOLOCK)
		JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
			AND CD.intContractStatusId <> 3 AND CD.intContractStatusId <> 2 AND CD.dtmCreated > '2018-01-01' AND ISNULL(CD.strERPPONumber, '') = ''
		JOIN tblSMTransaction TR WITH (NOLOCK) ON TR.intRecordId = CH.intContractHeaderId
			AND TR.intScreenId = 11 AND ISNULL(TR.ysnOnceApproved, 0) = 1
		LEFT JOIN tblCTContractFeed CF WITH (NOLOCK) ON CF.intContractDetailId = CD.intContractDetailId
		WHERE CF.intContractFeedId IS NULL

		-- Quantity mismatch between contract detail and feed table
		SELECT @strDetail=@strDetail + 
		'<tr>
			   <td>&nbsp;' + ISNULL(CH.strContractNumber,'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,CD.intContractSeq),'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(LTRIM(CD.intContractHeaderId), '') + '</td>'
			+ '<td>&nbsp;' + 'Quantity Mismatch' + '</td>
		</tr>'
		FROM tblCTContractDetail CD WITH (NOLOCK)
		JOIN vyuCTGridContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
			AND CD.intContractStatusId <> 3 AND CD.dtmCreated > '2018-01-01' AND ISNULL(CD.strERPPONumber, '') <> ''
			AND CH.strApprovalStatus NOT IN ('Waiting for Submit','Waiting for Approval')
			AND CH.strContractNumber NOT IN ('1005397.61','1005397.63','1005397.61','1005247.708','1005293.27','1005268.87')
		JOIN tblCTContractFeed CF WITH (NOLOCK) ON CF.intContractDetailId = CD.intContractDetailId
		WHERE CD.dblQuantity <> CF.dblQuantity
			AND CF.intContractFeedId IN (SELECT MAX(CF1.intContractFeedId) FROM tblCTContractFeed CF1 WITH (NOLOCK) WHERE CF1.intContractDetailId = CF.intContractDetailId)
	END

	SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
	SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strDetail, '') = ''
		SET @strMessage = ''

	SELECT @strMessage AS strMessage
