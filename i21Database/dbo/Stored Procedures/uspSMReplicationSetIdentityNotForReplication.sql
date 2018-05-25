
GO
CREATE PROCEDURE [dbo].[uspSMReplicationSetIdentityNotForReplication] 
@tableName as nvarchar(100)
AS
BEGIN
		Declare @int int;
		set @int =object_id(@tableName)
		EXEC sys.sp_identitycolumnforreplication @int, 1
			
End