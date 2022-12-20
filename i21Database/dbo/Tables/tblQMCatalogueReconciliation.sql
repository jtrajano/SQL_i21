CREATE TABLE [dbo].[tblQMCatalogueReconciliation]
(
	[intCatalogueReconciliationId] 		INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] 			        INT NULL DEFAULT ((1)),
	[intEntityId]						INT NOT NULL,
    [strReconciliationNumber] 	        NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strComments] 	                    NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
    [dtmReconciliationDate] 			DATETIME NULL,
	[ysnPosted]							BIT NULL DEFAULT(0),
	[dtmPostDate]						DATETIME NULL,
	[ysnReadOnly]						BIT NULL DEFAULT(0),
	CONSTRAINT [PK_tblQMCatalogueReconciliation_intCatalogueReconciliationId] PRIMARY KEY CLUSTERED ([intCatalogueReconciliationId] ASC)
);
GO
CREATE NONCLUSTERED INDEX [IX_tblQMCatalogueReconciliation_strReconciliationNumber] ON [dbo].[tblQMCatalogueReconciliation](strReconciliationNumber)
GO
CREATE TRIGGER trgCatalogueReconciliationNumber
	ON dbo.tblQMCatalogueReconciliation
AFTER INSERT
AS

DECLARE @inserted TABLE(intCatalogueReconciliationId INT)
DECLARE @intCatalogueReconciliationId INT
DECLARE @strReconciliationNumber NVARCHAR(50)
DECLARE @intStartingNumberId INT = (SELECT TOP 1 intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Catalogue Reconciliation')

INSERT INTO @inserted
SELECT intCatalogueReconciliationId FROM INSERTED WHERE ISNULL(RTRIM(LTRIM(strReconciliationNumber)), '') = '' ORDER BY intCatalogueReconciliationId

WHILE EXISTS (SELECT TOP 1 NULL FROM @inserted) AND ISNULL(@intStartingNumberId, 0) > 0
	BEGIN
		SELECT TOP 1 @intCatalogueReconciliationId = intCatalogueReconciliationId FROM @inserted
		SET @strReconciliationNumber = NULL

		EXEC dbo.uspSMGetStartingNumber @intStartingNumberId, @strReconciliationNumber OUT, NULL

		IF(@strReconciliationNumber IS NOT NULL)
			BEGIN
				WHILE EXISTS (SELECT TOP 1 1 FROM tblQMCatalogueReconciliation WHERE strReconciliationNumber = @strReconciliationNumber)
					BEGIN
						EXEC uspSMGetStartingNumber @intStartingNumberId, @strReconciliationNumber OUT, NULL			
					END

				UPDATE tblQMCatalogueReconciliation
				SET strReconciliationNumber = @strReconciliationNumber
				WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId
			END

			DELETE FROM @inserted
			WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId
	END
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_tblQMCatalogueReconciliation_strReconciliationNumber]
	ON dbo.tblQMCatalogueReconciliation(strReconciliationNumber)
	WHERE strReconciliationNumber IS NOT NULL;
GO