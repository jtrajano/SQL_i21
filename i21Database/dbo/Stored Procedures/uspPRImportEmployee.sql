CREATE PROCEDURE dbo.uspPRImportEmployee(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

SELECT * FROM tblApiSchemaEmployee

GO


