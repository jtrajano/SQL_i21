CREATE TABLE [dbo].[tblMFRecipeAlertLog]
(
	[intRecipeAlertLogId] INT NOT NULL IDENTITY(1,1),
	[intAuditLogId] INT
	CONSTRAINT [PK_tblMFRecipeAlertLog_intRecipeAlertLogId] PRIMARY KEY ([intRecipeAlertLogId]),
)
