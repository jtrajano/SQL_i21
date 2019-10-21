CREATE TABLE [dbo].[tblSMDocumentMaintenance]
(
	[intDocumentMaintenanceId]			INT NOT NULL IDENTITY, 
    [strCode]		NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL, 
    [strTitle]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL, 
	[intCompanyLocationId]  INT NULL,
	[intLineOfBusinessId]	INT NULL,
    [intEntityCustomerId]	INT NULL, 
	[strSource]				NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strType]			    NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL, 
	[ysnCopyAll]			BIT NOT NULL DEFAULT 0,
    [intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblSMDocumentMaintenance_intDocumentId] PRIMARY KEY CLUSTERED ([intDocumentMaintenanceId] ASC),
	CONSTRAINT [FK_tblSMDocumentMaintenance_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblSMDocumentMaintenance_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]), 
    CONSTRAINT [FK_tblSMDocumentMaintenance_tblSMLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [tblSMLineOfBusiness]([intLineOfBusinessId]),
    CONSTRAINT [AK_tblSMDocumentMaintenance_strCode] UNIQUE ([strCode])
)

GO

CREATE TRIGGER [dbo].[trgDocumentCode]
ON [dbo].[tblSMDocumentMaintenance]
AFTER INSERT
AS

DECLARE @inserted TABLE(intDocumentId INT)
DECLARE @intDocumentId INT
DECLARE @strDocumentCode NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT [intDocumentMaintenanceId] FROM INSERTED ORDER BY [intDocumentMaintenanceId]
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intDocumentId = intDocumentId FROM @inserted

	EXEC uspSMGetStartingNumber 67, @strDocumentCode OUT

	IF(@strDocumentCode IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM [tblSMDocumentMaintenance] WHERE [strCode] = @strDocumentCode)
			BEGIN
				SET @strDocumentCode = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING([strCode], 5, 10))) FROM [tblSMDocumentMaintenance]
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 67
				EXEC uspSMGetStartingNumber 67, @strDocumentCode OUT
			END
		
		UPDATE [tblSMDocumentMaintenance]
			SET [tblSMDocumentMaintenance].[strCode] = @strDocumentCode
		FROM [tblSMDocumentMaintenance] A
		WHERE A.[intDocumentMaintenanceId] = @intDocumentId
	END

	DELETE FROM @inserted
	WHERE intDocumentId = @intDocumentId
END