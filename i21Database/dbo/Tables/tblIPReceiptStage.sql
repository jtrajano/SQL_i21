CREATE TABLE [dbo].[tblIPReceiptStage]
(
	intStageReceiptId INT IDENTITY(1,1),
	strDeliveryNo	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL ,
	dtmReceiptDate	DATETIME ,
	dtmTransactionDate DATETIME NULL  DEFAULT((getdate())),
	CONSTRAINT [PK_tblIPReceiptStage_intStageReceiptId] PRIMARY KEY ([intStageReceiptId]) 
)
