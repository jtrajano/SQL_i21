CREATE TABLE [dbo].[tblSMCommentMaintenance]
(
	[intCommentMaintenanceId]			INT NOT NULL IDENTITY, 
    [strCommentCode]		NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL, 
    [strCommentTitle]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL, 
	[intCompanyLocationId]  INT NULL,
	[intLineOfBusinessId]	INT NULL,
    [intEntityCustomerId]	INT NULL, 
	[strHeaderFooter]		NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strSource]				NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strType]			    NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL, 
	[ysnCopyAll]			BIT NOT NULL DEFAULT 0,
    [intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblSMCommentMaintenance_intCommentId] PRIMARY KEY CLUSTERED ([intCommentMaintenanceId] ASC),
	CONSTRAINT [FK_tblSMCommentMaintenance_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblSMCommentMaintenance_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]), 
    CONSTRAINT [FK_tblSMCommentMaintenance_tblSMLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [tblSMLineOfBusiness]([intLineOfBusinessId]),
    CONSTRAINT [AK_tblSMCommentMaintenance_strCommentCode] UNIQUE ([strCommentCode])
)

GO

CREATE TRIGGER [dbo].[trgCommentCode]
ON [dbo].[tblSMCommentMaintenance]
AFTER INSERT
AS

DECLARE @inserted TABLE(intCommentId INT)
DECLARE @intCommentId INT
DECLARE @strCommentCode NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT [intCommentMaintenanceId] FROM INSERTED ORDER BY [intCommentMaintenanceId]
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intCommentId = intCommentId FROM @inserted

	EXEC uspSMGetStartingNumber 67, @strCommentCode OUT

	IF(@strCommentCode IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM [tblSMCommentMaintenance] WHERE strCommentCode = @strCommentCode)
			BEGIN
				SET @strCommentCode = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strCommentCode, 5, 10))) FROM [tblSMCommentMaintenance]
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 67
				EXEC uspSMGetStartingNumber 67, @strCommentCode OUT
			END
		
		UPDATE [tblSMCommentMaintenance]
			SET [tblSMCommentMaintenance].strCommentCode = @strCommentCode
		FROM [tblSMCommentMaintenance] A
		WHERE A.[intCommentMaintenanceId] = @intCommentId
	END

	DELETE FROM @inserted
	WHERE intCommentId = @intCommentId
END