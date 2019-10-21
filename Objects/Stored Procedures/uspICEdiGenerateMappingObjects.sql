CREATE PROCEDURE [dbo].[uspICEdiGenerateMappingObjects] @Identifier NVARCHAR(10), @UniqueId UNIQUEIDENTIFIER
AS
DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

SELECT @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME([Key])
FROM (SELECT DISTINCT o.[Key] FROM tblICEdiMapObject o WHERE Identifier = @Identifier) AS Keys

SET @DynamicPivotQuery =
N'SELECT [FileIndex], [RecordIndex], ' + @ColumnName + '
FROM
(
	SELECT o.[FileIndex], o.[RecordIndex], o.[Key], NULLIF(RTRIM(LTRIM(o.[Value])), '''') [Value], o.Content
	FROM tblICEdiMapObject o
		INNER JOIN tblICEdiMap m ON m.Id = o.MapId
	WHERE o.Identifier = @p0
		AND m.UniqueId = @p1
) AS T
PIVOT(MAX([Value])
	FOR [Key] IN (' + @ColumnName + ')) AS PvtTable Order BY [RecordIndex] ASC'

EXEC sp_executesql @DynamicPivotQuery, N'@p0 NVARCHAR(50), @p1 UNIQUEIDENTIFIER', @Identifier, @UniqueId