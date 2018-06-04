CREATE TABLE [dbo].[tblARCommission]
(
	[intCommissionId]			INT NOT NULL IDENTITY,
	[intCommissionScheduleId]	INT NOT NULL,
	[intCommissionPlanId]		INT NULL,
	[intEntityId]				INT NULL,
	[intApproverEntityId]		INT NULL,
	[intPaymentId]				INT NULL,
	[intPaycheckId]				INT NULL,
	[dtmStartDate]				DATETIME NULL,
	[dtmEndDate]				DATETIME NULL,
	[ysnConditional]			BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnConditional] DEFAULT ((0)),
	[ysnApproved]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnApproved] DEFAULT ((0)),
	[ysnRejected]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnRejected] DEFAULT ((0)),
	[ysnPayroll]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPayroll] DEFAULT ((0)),
	[ysnPayables]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPayables] DEFAULT ((0)),
	[ysnPosted]					BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPosted] DEFAULT ((0)),
	[ysnPaid]					BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPaid] DEFAULT ((0)),
	[dblTotalAmount]			NUMERIC(18,6) NOT NULL DEFAULT 0,
	[strCommissionNumber]		NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,	
	[strReason]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARCommission_intCommissionId] PRIMARY KEY CLUSTERED ([intCommissionId] ASC),
	CONSTRAINT [FK_tblARCommission_tblAPPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [tblAPPayment]([intPaymentId]),
	CONSTRAINT [FK_tblARCommission_tblPRPaycheck_intPaycheckId] FOREIGN KEY ([intPaycheckId]) REFERENCES [tblPRPaycheck]([intPaycheckId])
);

GO
CREATE TRIGGER trgCommissionNumber
ON dbo.tblARCommission
AFTER INSERT
AS

DECLARE @inserted TABLE(intCommissionId INT)
DECLARE @count INT = 0
DECLARE @intCommissionId INT
DECLARE @strCommissionNumber NVARCHAR(50)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = (SELECT TOP 1 intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Commission')

INSERT INTO @inserted
SELECT intCommissionId FROM INSERTED WHERE strCommissionNumber IS NULL ORDER BY intCommissionId

WHILE EXISTS (SELECT TOP 1 NULL FROM @inserted) AND ISNULL(@intStartingNumberId, 0) > 0
	BEGIN
		SELECT TOP 1 @intCommissionId = intCommissionId FROM @inserted
		SET @strCommissionNumber = NULL

		EXEC dbo.uspSMGetStartingNumber @intStartingNumberId, @strCommissionNumber OUT, NULL

		IF(@strCommissionNumber IS NOT NULL)
			BEGIN
				IF EXISTS (SELECT NULL FROM tblARCommission WHERE strCommissionNumber = @strCommissionNumber)
					BEGIN
						SET @strCommissionNumber = NULL
				
						UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
						EXEC uspSMGetStartingNumber @intStartingNumberId, @strCommissionNumber OUT, NULL			
					END

				UPDATE tblARCommission
				SET strCommissionNumber = @strCommissionNumber
				WHERE intCommissionId = @intCommissionId
			END

			DELETE FROM @inserted
			WHERE intCommissionId = @intCommissionId
	END
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_tblARCommission_strCommissionNumber]
ON dbo.tblARCommission(strCommissionNumber)
WHERE strCommissionNumber IS NOT NULL;