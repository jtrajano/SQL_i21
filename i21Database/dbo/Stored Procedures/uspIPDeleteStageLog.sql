CREATE PROCEDURE dbo.uspIPDeleteStageLog (@intNoOfDay INT = 30)
AS
BEGIN
	DECLARE @dtmDate DATETIME

	SELECT @dtmDate = CONVERT(VARCHAR(10), GETDATE() - @intNoOfDay, 126) + ' 00:00:00'

	DELETE
	FROM tblCTContractPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblCTPriceContractPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblLGIntrCompLogisticsPreStg
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblMFDemandPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblQMSamplePreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblICItemPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblCTContractStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblCTPriceContractStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblLGIntrCompLogisticsStg
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblQMSampleStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblICItemStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblMFDemandStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblCTContractAcknowledgementStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblCTPriceContractAcknowledgementStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblLGIntrCompLogisticsAck
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblQMSampleAcknowledgementStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblMFDemandAcknowledgementStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblLGFreightRateMatrixPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblLGFreightRateMatrixStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblLGFreightRateMatrixAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblRKCoverageEntryPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblRKCoverageEntryStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblRKCoverageEntryAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblRKFutOptTransactionHeaderPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblRKFutOptTransactionHeaderStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblRKFutOptTransactionHeaderAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblRKFuturesMonthPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblRKFuturesMonthStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblRKFuturesMonthAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblRKFuturesSettlementPricePreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblRKFuturesSettlementPriceStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblRKFuturesSettlementPriceAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblRKM2MBasisPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblRKM2MBasisStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblRKM2MBasisAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)

	DELETE
	FROM tblRKOptionsMonthPreStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus = 'Processed'

	DELETE
	FROM tblRKOptionsMonthStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Processed'
			,'Ack Rcvd'
			)

	DELETE
	FROM tblRKOptionsMonthAckStage
	WHERE dtmFeedDate < @dtmDate
		AND strFeedStatus IN (
			'Ack Processed'
			,'Ack Sent'
			)
END
