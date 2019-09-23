/*
REMOVE INDEX FROM OBSOLETE REPORT GL By Account Id Detail Report
*/
GO
PRINT ('Begin removing unused GL Table Index')
GO

DECLARE @tblIndex TABLE (
	strIndex NVARCHAR(100)
)
DECLARE @strIndex NVARCHAR(100)
insert into @tblIndex
select 'IX_tblGLDetail_intAccountId_ysnIsUnposted' union
select 'IX_tblGLDetail_dtmDate' union
select 'IX_tblGLDetail_strTransactionId' union
select 'IX_tblGLDetail_ysnIsUnposted'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblIndex)
BEGIN
    SELECT TOP 1 @strIndex = strIndex from @tblIndex
    IF EXISTS (SELECT 1
                FROM sys.indexes I
                    INNER JOIN sys.tables T
                        ON I.object_id = T.object_id
                    INNER JOIN sys.schemas S
                        ON S.schema_id = T.schema_id
                WHERE I.name = @strIndex -- Index name
                    AND T.name = 'tblGLDetail' -- Table name
                    AND S.name = 'dbo') --Schema Name
    BEGIN
        
        EXEC ('drop index tblGLDetail.' + @strIndex ) 
    END
    DELETE FROM @tblIndex WHERE strIndex = @strIndex
END

GO
PRINT ('Finished removing unused GL Table Index')
GO
