CREATE TABLE tblCTPriceContractAcknowledgementStage
(
	intPriceContractAcknowledgementStageId				    INT IDENTITY(1,1) PRIMARY KEY, 
	intAckPriceContractId									INT,
	strAckPriceContracNo									NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strAckPriceContractXML									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckPriceFixationXML									NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckPriceFixationDetailXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strReference											NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState												NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus											NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate												DATETIME,
	strMessage												NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId										INT,
	strTransactionType										NVARCHAR(100) COLLATE Latin1_General_CI_AS
)