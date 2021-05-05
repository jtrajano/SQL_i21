CREATE TABLE tblAPBillPreStage
(
	intBillPreStageId				INT IDENTITY(1,1) PRIMARY KEY, 
	intBillId						INT,
	strRowState						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intUserId						INT,
	strFeedStatus					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblAPBillPreStage_dtmFeedDate DEFAULT GETDATE(),
	intStatusId						INT,
	strERPVoucherNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnMailSent						BIT DEFAULT 0,
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)