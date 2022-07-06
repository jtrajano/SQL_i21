CREATE PROCEDURE [dbo].[uspIPUnfixedPurchaseContract]
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
SET @strHeader = '<tr>
						<th>&nbsp;Inventory Receipt (IR) Number</th>
						<th>&nbsp;Inventory Receipt (IR) Date</th>
						<th>&nbsp;Contract Number</th>
						<th>&nbsp;Contract Sequence Number</th>
						<th>&nbsp;AX PO Number</th>
						<th>&nbsp;Vendor</th>
						<th>&nbsp;Delivery From</th>
						<th>&nbsp;Delivery To</th>
					</tr>'
SELECT @strDetail = @strDetail + '<tr>
			 <td>&nbsp;' + DT.strReceiptNumber + '</td>'+
			'<td>&nbsp;' + Convert(char,DT.dtmReceiptDate,101) + '</td>' +
			'<td>&nbsp;' + DT.strContractNumber  + '</td>' + 
			'<td>&nbsp;' + ltrim(DT.intContractSeq ) + '</td>' + 
			'<td>&nbsp;' + ISNULL(DT.strERPPONumber , '') + '</td>'+
			'<td>&nbsp;' + DT.strName  + '</td>'+
			'<td>&nbsp;' + Convert(char,DT.dtmStartDate,101)  + '</td>'+
		    '<td>&nbsp;' + Convert(char,DT.dtmEndDate,101) + '</td>
</tr>'
FROM (
	SELECT DISTINCT R.strReceiptNumber,R.dtmReceiptDate
		,CH.strContractNumber
		,ltrim(CD.intContractSeq) AS intContractSeq
		,ISNULL(CD.strERPPONumber, '') AS strERPPONumber
		,E.strName 
		,CD.dtmStartDate 
		,CD.dtmEndDate 
	FROM dbo.tblCTContractDetail CD
	JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN dbo.tblICInventoryReceiptItem RI ON RI.intContractDetailId = CD.intContractDetailId
	JOIN dbo.tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	JOIN tblEMEntity E on E.intEntityId =CH.intEntityId  
	WHERE CD.intContractStatusId = 1
		AND CD.intPricingTypeId = 2
		AND CD.dblBalance = 0
	) AS DT
SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
