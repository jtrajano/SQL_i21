CREATE TABLE [dbo].[tblARCommentMaintenance]
(
	[intCommentId]			INT NOT NULL IDENTITY, 
    [strCommentCode]		NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL, 
    [strCommentTitle]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCommentDesc]		NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionType]	NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strType]			    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityCustomerId]	INT NULL, 
    [intCompanyLocationId]  INT NULL,
	[intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommentMaintenance_intCommentId] PRIMARY KEY CLUSTERED ([intCommentId] ASC),
	CONSTRAINT [FK_tblARCommentMaintenance_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblARCommentMaintenance_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]), 
    CONSTRAINT [AK_tblARCommentMaintenance_strCommentCode] UNIQUE ([strCommentCode])
)

GO

CREATE TRIGGER [dbo].[trgCommentCode]
ON [dbo].[tblARCommentMaintenance]
AFTER INSERT
AS

DECLARE @inserted TABLE(intCommentId INT)
DECLARE @intCommentId INT
DECLARE @strCommentCode NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intCommentId FROM INSERTED ORDER BY intCommentId
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intCommentId = intCommentId FROM @inserted

	EXEC uspSMGetStartingNumber 67, @strCommentCode OUT

	IF(@strCommentCode IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARCommentMaintenance WHERE strCommentCode = @strCommentCode)
			BEGIN
				SET @strCommentCode = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strCommentCode, 5, 10))) FROM tblARCommentMaintenance
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 67
				EXEC uspSMGetStartingNumber 67, @strCommentCode OUT
			END
		
		UPDATE tblARCommentMaintenance
			SET tblARCommentMaintenance.strCommentCode = @strCommentCode
		FROM tblARCommentMaintenance A
		WHERE A.intCommentId = @intCommentId
	END

	DELETE FROM @inserted
	WHERE intCommentId = @intCommentId
END