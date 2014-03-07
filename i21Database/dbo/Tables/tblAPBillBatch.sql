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

DECLARE @inserted TABLE(intBillBatchId INT)
DECLARE @count INT = 0
DECLARE @intBillBatchId INT
DECLARE @BillBatchId NVARCHAR(50)

INSERT INTO @inserted
SELECT intBillBatchId FROM INSERTED ORDER BY intBillBatchId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN

	EXEC uspSMGetStartingNumber 7, @BillBatchId OUT

	SELECT TOP 1 @intBillBatchId = intBillBatchId FROM @inserted

	IF(@BillBatchId IS NOT NULL)
	BEGIN
		UPDATE tblAPBillBatch
			SET tblAPBillBatch.strBillBatchNumber = @BillBatchId
		FROM tblAPBillBatch A
		WHERE A.intBillBatchId = @intBillBatchId
	END

	DELETE FROM @inserted
	WHERE intBillBatchId = @intBillBatchId

END