CREATE PROCEDURE [dbo].[uspARRebuildCustomerAgingDetailReport]
       @intEntityUserId INT = 0
AS

	EXEC uspARCustomerAgingDetailAsOfDateReport @intEntityUserId = @intEntityUserId

GO