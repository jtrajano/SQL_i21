CREATE TABLE [dbo].[tblAPBill] (
    [intBillId]            INT             IDENTITY (1, 1) NOT NULL,
    [intBillBatchId]       INT             NULL,
    [strVendorId]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]           INT             NOT NULL,
    [intTaxCodeId]         INT             NULL,
    [dtmDate]              DATETIME        NOT NULL,
    [dtmDueDate]           DATETIME        NOT NULL,
    [intAccountId]         INT             NULL,
    [strDescription]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]             DECIMAL (18, 2) NOT NULL,
    [ysnPosted]            BIT             NOT NULL,
    [ysnPaid]              BIT             NOT NULL,
    [strBillId]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblAmountDue]         DECIMAL (18, 2) NOT NULL,
    [dtmDatePaid]          DATETIME        NULL,
    [dtmDiscountDate]      DATETIME        NULL,
    [intUserId]            INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmBillDate] DATETIME NOT NULL, 
    [intEntityId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([intBillId] ASC),
    CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatch] ([intBillBatchId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_intBillBatchId]
    ON [dbo].[tblAPBill]([intBillBatchId] ASC);


GO
CREATE TRIGGER trgBillRecordNumber
ON tblAPBill
AFTER INSERT
AS

DECLARE @inserted TABLE(intBillId INT)
DECLARE @count INT = 0
DECLARE @intBillId INT
DECLARE @BillId NVARCHAR(50)

INSERT INTO @inserted
SELECT intBillId FROM INSERTED ORDER BY intBillId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	
	EXEC uspAPFixStartingNumbers 9
	--IF(OBJECT_ID('tempdb..#tblTempAPByPassFixStartingNumber') IS NOT NULL) RETURN;
	EXEC uspSMGetStartingNumber 9, @BillId OUT

	SELECT TOP 1 @intBillId = intBillId FROM @inserted
	
	IF(@BillId IS NOT NULL)
	BEGIN
		UPDATE tblAPBill
			SET tblAPBill.strBillId = @BillId
		FROM tblAPBill A
		WHERE A.intBillId = @intBillId
		--INNER JOIN INSERTED B ON A.intBillId = B.intBillId
		--WHERE A.strBillId IS NULL
	END

	DELETE FROM @inserted
	WHERE intBillId = @intBillId

END


