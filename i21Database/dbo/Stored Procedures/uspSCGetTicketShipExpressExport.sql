CREATE PROCEDURE [dbo].[uspSCGetTicketShipExpressExport]
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
	DECLARE @dblGrossUnit NUMERIC(18,6)
	DECLARE @dblNetUnit NUMERIC(18,6)

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
	

	--Actuals
	SELECT TOP 1 
		[Actuals_Id] = 0
		,[ETSBOLDocNumber] = strTicketNumber
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId


	----Actual
	EXEC('SELECT
				Actuals_Id = 0 
				,actual_Id = 0
				,[CarPrefix] = ISNULL(AA.strTruckName,'''')
				,[CarNumber] = ISNULL(AA.strTrailerId,'''')
				,[BOLNumber] = ISNULL(AA.strTicketNumber,'''')
				,[TemplateName] = ISNULL(AA.strDriverName,'''')
				,[BOLType] = ''S''
				,[UnitTrainID] = ''''
				,[LoadStopDate] = ''''
				,[ScheduledDate] = CONVERT(varchar, AA.dtmTicketDateTime, 112)
				,[ContractNumber] = ISNULL(AA.strContractNumber,'''')
				,[CustomerPONumber] = ISNULL(C.strBLNumber,'''')
				,CIValue = ''''
				,' + @SealNumberColumns +'
			FROM vyuSCTicketScreenView AA
			LEFT JOIN tblLGLoadDetail B
				ON AA.intLoadDetailId = B.intLoadDetailId
			LEFT JOIN tblLGLoad C
				ON B.intLoadId = C.intLoadId
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

	--quantity
	BEGIN
		SELECT
			@dblGrossUnit = dblGrossUnits
			,@dblNetUnit = dblNetUnits
		FROM tblSCTicket
		WHERE intTicketId = @intTicketId

		SELECT
			[actual_Id] = 0
			,[value] = @dblGrossUnit
			,[type] = 'gross'
		UNION
		SELECT
			[actual_Id] = 0
			,[value] = @dblNetUnit
			,[type] = 'net'
			
	END

	--certificateOfAnalysisInfo
	BEGIN
		SELECT 
			[actual_Id] = 0
			,[certificateOfAnalysisInfo_id] = 0 

	END

	--CofA
	BEGIN
		SELECT 
			[certificateOfAnalysisInfo_id] = 0
			,[type] = B.strCertificate
			,[value] = A.dblReading
		FROM tblSCTicketCertificateOfAnalysis A
		INNER JOIN tblSCCertificateOfAnalysis B
			ON A.intCertificateOfAnalysisId = B.intCertificateOfAnalysisId
		WHERE intTicketId = @intTicketId
	END
END

GO
