CREATE PROCEDURE uspIPInterCompanySendEmail @strMessageType NVARCHAR(50)
	,@strStatus NVARCHAR(50)
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

IF @strMessageType = 'Sample'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Sample No</th>
						<th>&nbsp;Sample Type</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strNewSampleNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strNewSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMSampleStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strNewSampleNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strNewSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMSampleStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'DAP'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Average No</th>
						<th>&nbsp;Date</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strAverageNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(DAP.dtmDate, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKDailyAveragePriceStage S WITH (NOLOCK)
		JOIN tblRKDailyAveragePrice DAP ON DAP.intDailyAveragePriceId = S.intDailyAveragePriceId
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKDailyAveragePriceStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strAverageNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(DAP.dtmDate, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblRKDailyAveragePriceStage S WITH (NOLOCK)
		JOIN tblRKDailyAveragePrice DAP ON DAP.intDailyAveragePriceId = S.intDailyAveragePriceId
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKDailyAveragePriceStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Item'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Item</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strItemNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblICItemStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblICItemStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strItemNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblICItemStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblICItemStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Contract'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Contract Number</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strContractNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblCTContractStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblCTContractStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strContractNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblCTContractStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblCTContractStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Price Contract'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Contract Number</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strPriceContractNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblCTPriceContractStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblCTPriceContractStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strPriceContractNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblCTPriceContractStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblCTPriceContractStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Load'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Load Number</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strLoadNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblLGIntrCompLogisticsStg S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblLGIntrCompLogisticsStg
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strLoadNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblLGIntrCompLogisticsStg S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblLGIntrCompLogisticsStg
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Demand'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Plan Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strInvPlngReportName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblMFDemandStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblMFDemandStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strInvPlngReportName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblMFDemandStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblMFDemandStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'WeightClaim'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Claim No</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strReferenceNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblLGWeightClaimStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblLGWeightClaimStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strReferenceNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblLGWeightClaimStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblLGWeightClaimStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Derivative'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Transaction Id</th>
						<th>&nbsp;Transaction Date</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutOptTransactionHeaderId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmTransactionDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKFutOptTransactionHeaderStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKFutOptTransactionHeaderStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutOptTransactionHeaderId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmTransactionDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKFutOptTransactionHeaderStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKFutOptTransactionHeaderStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Coverage'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Batch Name</th>
						<th>&nbsp;Date</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strBatchName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKCoverageEntryStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKCoverageEntryStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strBatchName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKCoverageEntryStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKCoverageEntryStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Option Lifecycle'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Header Id</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intOptionsMatchPnSHeaderId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKOptionsMatchPnSHeaderStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKOptionsMatchPnSHeaderStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intOptionsMatchPnSHeaderId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKOptionsMatchPnSHeaderStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKOptionsMatchPnSHeaderStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

-- Master Screens

IF @strMessageType = 'Freight Rate Matrix'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFreightRateMatrixId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblLGFreightRateMatrixStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblLGFreightRateMatrixStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFreightRateMatrixId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblLGFreightRateMatrixStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblLGFreightRateMatrixStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Futures Month'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureMonthId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFutureMonth, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKFuturesMonthStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKFuturesMonthStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureMonthId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFutureMonth, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKFuturesMonthStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKFuturesMonthStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Options Month'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intOptionMonthId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strOptionMonth, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKOptionsMonthStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKOptionsMonthStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intOptionMonthId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strOptionMonth, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKOptionsMonthStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKOptionsMonthStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Settlement Price'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureSettlementPriceId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKFuturesSettlementPriceStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKFuturesSettlementPriceStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureSettlementPriceId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKFuturesSettlementPriceStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKFuturesSettlementPriceStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Basis Entry'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intM2MBasisId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKM2MBasisStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKM2MBasisStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intM2MBasisId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKM2MBasisStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKM2MBasisStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Attribute'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intAttributeId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strAttributeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMAttributeStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMAttributeStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intAttributeId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strAttributeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMAttributeStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMAttributeStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'List'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intListId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strListName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMListStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMListStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intListId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strListName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMListStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMListStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Sample Type'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intSampleTypeId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMSampleTypeStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMSampleTypeStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intSampleTypeId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMSampleTypeStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMSampleTypeStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Property'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intPropertyId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strPropertyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMPropertyStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMPropertyStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intPropertyId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strPropertyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMPropertyStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMPropertyStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Test'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intTestId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strTestName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMTestStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMTestStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intTestId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strTestName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMTestStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMTestStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'Template'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intProductId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strProductName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMProductStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMProductStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intProductId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strProductName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMProductStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMProductStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END


SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
