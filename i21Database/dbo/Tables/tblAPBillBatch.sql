CREATE TABLE [dbo].[tblAPBillBatch] (
    [intBillBatchId]     INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]       INT             NOT NULL,
    [ysnPosted]          BIT             DEFAULT ((0)) NULL,
    [strBillBatchNumber] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strReference]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]           DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.tblAPBillBatches] PRIMARY KEY CLUSTERED ([intBillBatchId] ASC)
);


GO
CREATE TRIGGER trgBillBatchRecordNumber
ON tblAPBillBatch
AFTER INSERT
AS
	DECLARE @BillBatchId NVARCHAR(50)
	EXEC uspSMGetStartingNumber 7, @BillBatchId OUT

	IF(@BillBatchId IS NOT NULL)
	BEGIN
	UPDATE tblAPBillBatch
		SET tblAPBillBatch.strBillBatchNumber = @BillBatchId
	FROM tblAPBillBatch A
		INNER JOIN INSERTED B ON A.intBillBatchId = B.intBillBatchId
	END
