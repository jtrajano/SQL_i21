CREATE TABLE [dbo].[tblIPReceiptStage]
(
	intStageReceiptId INT IDENTITY(1,1),
	strDeliveryNo	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL ,
	strExternalRefNo	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL ,
	dtmReceiptDate	DATETIME ,
	dtmTransactionDate DATETIME NULL  DEFAULT((getdate())),
	strPartnerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblIPReceiptStage_intStageReceiptId] PRIMARY KEY ([intStageReceiptId]) 
)
