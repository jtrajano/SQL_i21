CREATE PROCEDURE uspIPInterCompanySendEmail @strMessageType NVARCHAR(50)
	,@strStatus NVARCHAR(50) = ''
	,@ysnDailyNotification BIT=0
	,@intStatusId INT = NULL
AS
DECLARE @strStyle NVARCHAR(MAX)
	,@strHtml NVARCHAR(MAX)
	,@strHeader NVARCHAR(MAX)
	,@strDetail NVARCHAR(MAX) = ''
	,@strMessage NVARCHAR(MAX)

IF @strStatus = 'Success'
	SELECT @intStatusId = 1 -- Processed
ELSE IF @strStatus = 'Failure'
	SELECT @intStatusId = 2 -- Failed

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

	IF EXISTS (
		SELECT 1
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strNewSampleNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strNewSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0

		UPDATE tblQMSampleStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
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

	IF EXISTS (
		SELECT 1
		FROM tblRKDailyAveragePriceStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strAverageNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), DAP.dtmDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblRKDailyAveragePriceStage S WITH (NOLOCK)
		JOIN tblRKDailyAveragePrice DAP WITH (NOLOCK) ON DAP.intDailyAveragePriceId = S.intDailyAveragePriceId
		WHERE S.intStatusId = @intStatusId
			AND S.ysnMailSent = 0

		UPDATE tblRKDailyAveragePriceStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
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

	IF EXISTS (
			SELECT *
			FROM tblCTContractStage S WITH (NOLOCK)
			WHERE intStatusId = @intStatusId --1--Processed/2--Failed
				AND ysnMailSent IS NULL
			)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strContractNumber, '') + '</td>' 
			   + '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' 
			   + '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' 
			   + '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblCTContractStage S WITH (NOLOCK)
		LEFT JOIN tblIPMultiCompany MC WITH (NOLOCK) ON MC.intCompanyId = S.intCompanyId
		WHERE S.intStatusId = @intStatusId --1--Processed/2--Failed
			AND S.ysnMailSent IS NULL

		UPDATE tblCTContractStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId --1--Processed/2--Failed
			AND ysnMailSent IS NULL
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
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblCTPriceContractStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE IF @strStatus = 'Failure'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strPriceContractNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblCTPriceContractStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
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
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblLGIntrCompLogisticsStg
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE IF @strStatus = 'Failure'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strLoadNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblLGIntrCompLogisticsStg S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
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
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblMFDemandStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE IF @strStatus = 'Failure'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strInvPlngReportName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblMFDemandStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
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
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
		WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
			AND ISNULL(S.ysnMailSent, 0) = 0

		UPDATE tblLGWeightClaimStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE IF @strStatus = 'Failure'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strReferenceNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(MC.strName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblLGWeightClaimStage S WITH (NOLOCK)
		Left JOIN tblIPMultiCompany MC WITH (NOLOCK) on MC.intCompanyId=S.intCompanyId
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

	IF EXISTS (
		SELECT 1
		FROM tblRKFutOptTransactionHeaderStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutOptTransactionHeaderId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmTransactionDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM (SELECT DISTINCT S.intFutOptTransactionHeaderId,S.dtmTransactionDate,S.strFromCompanyName,S.strMessage
		FROM tblRKFutOptTransactionHeaderStage S WITH (NOLOCK)
		WHERE S.intStatusId = @intStatusId
			AND S.ysnMailSent = 0) t

		UPDATE tblRKFutOptTransactionHeaderStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
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

	IF EXISTS (
		SELECT 1
		FROM tblRKCoverageEntryStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strBatchName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR(20), dtmDate, 106), '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblRKCoverageEntryStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0

		UPDATE tblRKCoverageEntryStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
	END
END

IF @strMessageType = 'Option Lifecycle'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Header Id</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF EXISTS (
		SELECT 1
		FROM tblRKOptionsMatchPnSHeaderStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intOptionsMatchPnSHeaderId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM (SELECT DISTINCT intOptionsMatchPnSHeaderId, strFromCompanyName, strMessage
		FROM tblRKOptionsMatchPnSHeaderStage WITH (NOLOCK)
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0) t

		UPDATE tblRKOptionsMatchPnSHeaderStage
		SET ysnMailSent = 1
		WHERE intStatusId = @intStatusId
			AND ysnMailSent = 0
	END
END

-- Master Screens

IF @strMessageType = 'Masters'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Name</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Message</th>
						<th>&nbsp;Screen</th>
					</tr>'

	IF EXISTS (
		SELECT 1
		FROM tblQMAttributeStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
				<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intAttributeId),'') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strAttributeName, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Attribute' + '</td>
		</tr>'
		FROM tblQMAttributeStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblQMAttributeStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblQMListStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
				<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intListId),'') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strListName, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'List' + '</td>
		</tr>'
		FROM tblQMListStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblQMListStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblQMSampleTypeStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intSampleTypeId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Sample Type' + '</td>
		</tr>'
		FROM tblQMSampleTypeStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblQMSampleTypeStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END
	
	IF EXISTS (
		SELECT 1
		FROM tblQMPropertyStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intPropertyId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strPropertyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Property' + '</td>
		</tr>'
		FROM tblQMPropertyStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblQMPropertyStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblQMTestStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intTestId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strTestName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Test' + '</td>
		</tr>'
		FROM tblQMTestStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblQMTestStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblQMProductStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intProductId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strProductName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Template' + '</td>
		</tr>'
		FROM tblQMProductStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblQMProductStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

-- IC, LG and RM Masters

	SELECT @strDetail = @strDetail + '<tr>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intItemId),'') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strItemNo, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			'<td>&nbsp;' + 'Success' + '</td>' + 
			'<td>&nbsp;' + 'Item' + '</td>
	</tr>'
	FROM tblICItemStage S WITH (NOLOCK)
	WHERE ISNULL(S.strFeedStatus, '') = 'Processed'
		AND ISNULL(S.ysnMailSent, 0) = 0

	UPDATE tblICItemStage
	SET ysnMailSent = 1
	WHERE ISNULL(strFeedStatus, '') = 'Processed'
		AND ISNULL(ysnMailSent, 0) = 0
			
	SELECT @strDetail = @strDetail + '<tr>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intItemId),'') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strItemNo, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>' + 
			'<td>&nbsp;' + 'Item' + '</td>
	</tr>'
	FROM tblICItemStage S WITH (NOLOCK)
	WHERE ISNULL(S.strFeedStatus, '') = 'Failed'
		AND ISNULL(S.ysnMailSent, 0) = 0

	UPDATE tblICItemStage
	SET ysnMailSent = 1
	WHERE ISNULL(strFeedStatus, '') = 'Failed'
		AND ISNULL(ysnMailSent, 0) = 0

	IF EXISTS (
		SELECT 1
		FROM tblLGFreightRateMatrixStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFreightRateMatrixId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Freight Rate Matrix' + '</td>
		</tr>'
		FROM tblLGFreightRateMatrixStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblLGFreightRateMatrixStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblRKFuturesMonthStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureMonthId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFutureMonth, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Futures Month' + '</td>
		</tr>'
		FROM tblRKFuturesMonthStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblRKFuturesMonthStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblRKOptionsMonthStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intOptionMonthId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strOptionMonth, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Options Month' + '</td>
		</tr>'
		FROM tblRKOptionsMonthStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblRKOptionsMonthStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblRKFuturesSettlementPriceStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureSettlementPriceId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Settlement Price' + '</td>
		</tr>'
		FROM tblRKFuturesSettlementPriceStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblRKFuturesSettlementPriceStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblRKM2MBasisStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intM2MBasisId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strDisplayName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Basis Entry' + '</td>
		</tr>'
		FROM tblRKM2MBasisStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblRKM2MBasisStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END

	IF EXISTS (
		SELECT 1
		FROM tblRKFutureMarketStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
		)
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intFutureMarketId),'') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFutMarketName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>' + 
				'<td>&nbsp;' + 'Forecast Price' + '</td>
		</tr>'
		FROM tblRKFutureMarketStage WITH (NOLOCK)
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0

		UPDATE tblRKFutureMarketStage
		SET ysnMailSent = 1
		WHERE intStatusId IS NOT NULL
			AND ysnMailSent = 0
	END
END

IF @ysnDailyNotification = 1
	AND @strMessageType = 'Item'
BEGIN
	DECLARE @dtmDate DATETIME
		,@dtmDate2 DATETIME

	SELECT @dtmDate = Convert(DATETIME, Convert(VARCHAR, GETDATE(), 101))

	SELECT @dtmDate2 = @dtmDate + 1
		SET @strHeader = '<tr>
						<th>&nbsp;Id</th>
						<th>&nbsp;Item</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;Date</th>
						<th>&nbsp;User</th>
					</tr>'


		SELECT @strDetail = @strDetail + '<tr>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR,intItemId),'') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strItemNo, '') + '</td>' + 
			'<td>&nbsp;' + ISNULL(S.strRowState, '') + '</td>' + 
			'<td>&nbsp;' + Ltrim(S.dtmFeedDate) + '</td>' +
			'<td>&nbsp;' + Ltrim(S.strUserName ) + '</td>' + 
			'</tr>'

		FROM tblICItemStage S WITH (NOLOCK)
		WHERE S.dtmFeedDate BETWEEN @dtmDate
				AND @dtmDate2 
				AND intMultiCompanyId =4
END

SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
