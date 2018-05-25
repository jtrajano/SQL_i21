
GO


CREATE PROCEDURE [dbo].[uspSMReplicationSetRangeStart]
 @tableName as nvarchar(100),
 @rangeStart as int
 As
 Begin
		DECLARE @result int;
		DECLARE @sql NVARCHAR(MAX) = N'';
		SET @sql += Replace(Replace(N'DBCC CHECKIDENT(@tbl, RESEED, @num)','@tbl', @tableName),'@num', @rangeStart)
                    
		--Executed Created Query
		EXEC @result = sp_executesql @sql;			
			
End