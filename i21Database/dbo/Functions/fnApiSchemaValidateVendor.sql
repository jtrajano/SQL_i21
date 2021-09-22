CREATE FUNCTION [dbo].[fnApiSchemaValidateVendor]
(
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
)
RETURNS @returntable TABLE
(
	guiApiImportLogDetailId UNIQUEIDENTIFIER NOT NULL,
	guiApiImportLogId UNIQUEIDENTIFIER NOT NULL,
	strLogLevel NVARCHAR(100) NOT NULL,
	strStatus NVARCHAR(150) NOT NULL,
	strAction NVARCHAR(150) NULL,
	intRowNo INT NULL,
	strField NVARCHAR(100) NULL,
	strValue NVARCHAR(4000) NULL,
	strMessage NVARCHAR(4000) NULL
)
AS
BEGIN
	-- --
	-- INSERT @returntable
	-- SELECT NEWID(), @guiLogId, 'Error', 'Failed', NULL, A.intRowNo, 'Item No', A.strValue, 'Item Number is not valid'

	-- --
	-- INSERT @returntable
	-- SELECT NEWID(), @guiLogId, 'Error', 'Failed', NULL, A.intRowNo, 'Item No', A.strValue, 'Item Number is not valid'

	-- --
	-- INSERT @returntable
	-- SELECT NEWID(), @guiLogId, 'Error', 'Failed', NULL, A.intRowNo, 'Item No', A.strValue, 'Item Number is not valid'
	
	RETURN
END