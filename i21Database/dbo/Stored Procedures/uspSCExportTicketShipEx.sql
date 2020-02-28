CREATE PROCEDURE [dbo].[uspSCExportTicketShipEx]
	@intTicketId INT
AS
BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


	DECLARE @SealNumberColumns NVARCHAR(MAX)
	DECLARE @strTicketId NVARCHAR(MAX)
	DECLARE @query NVARCHAR(MAX)

	SET @strTicketId = CAST(@intTicketId AS NVARCHAR(MAX))
	
	SELECT @SealNumberColumns = LEFT(intRecordId, LEN(intRecordId) - 1)
	FROM (
		SELECT '[Seal' + CAST(intRecordId AS VARCHAR(MAX))  + '],'
		FROM (
			SELECT intRecordId = ROW_NUMBER() OVER(PARTITION BY A.intTicketId ORDER BY A.intTicketSealNumberId ASC)
			FROM tblSCTicketSealNumber A
			WHERE A.intTicketId = @intTicketId
		) AA
		FOR XML PATH ('')
	
	) Z (intRecordId)
		
	EXEC('SELECT 
				AA.intTicketId
				,' + @SealNumberColumns +'
			FROM tblSCTicket AA
			OUTER APPLY(
				SELECT '  + @SealNumberColumns + '
				FROM
				(	
					SELECT 
						[Seal] = ''Seal'' + CAST((ROW_NUMBER() OVER(PARTITION BY A.intTicketId ORDER BY A.intTicketSealNumberId ASC)) AS NVARCHAR(MAX)) 
						, strSealNumber = ISNULL(B.strSealNumber,'''')
					FROM tblSCTicketSealNumber A
					INNER JOIN tblSCSealNumber B
						ON A.intSealNumberId = B.intSealNumberId
					WHERE A.intTicketId = AA.intTicketId
				) AS SourceTable
				PIVOT
				(
					MIN(strSealNumber)
					FOR Seal IN ('+ @SealNumberColumns +')
				) AS PivotTable
			)ZZ
			WHERE AA.intTicketId = ' + @strTicketId )


END
GO