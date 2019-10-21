CREATE PROCEDURE uspMFGetShiftActivityMachines
	@intShiftActivityId INT
	,@intManufacturingCellId INT
	,@intLocationId INT
	,@strSelected NVARCHAR(20)
	,@strMachineId NVARCHAR(MAX) = ''
	,@strName NVARCHAR(50) = ''
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SET @strMachineId = REPLACE(@strMachineId, '|^|', ',')

	SELECT A.*
	FROM (
		SELECT DISTINCT M.intMachineId
			,M.strName
			,M.strDescription
			,CONVERT(BIT, CASE 
					WHEN EXISTS (
							SELECT SM.intMachineId
							FROM dbo.tblMFShiftActivityMachines SM
							WHERE SM.intShiftActivityId = @intShiftActivityId
								AND SM.intMachineId = M.intMachineId
							)
						THEN 1
					ELSE 0
					END) AS ysnSelected
		FROM dbo.tblMFMachine M
		JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
		JOIN dbo.tblMFManufacturingCellPackType MCP ON MCP.intPackTypeId = MP.intPackTypeId
			AND MCP.intManufacturingCellId = @intManufacturingCellId
		WHERE M.intLocationId = @intLocationId
			AND M.intMachineId NOT IN (
				SELECT *
				FROM dbo.[fnSplitString](@strMachineId,',')
				)
			AND M.strName LIKE '%' + @strName + '%'
		) A
	WHERE A.ysnSelected = (
			CASE 
				WHEN @strSelected = 'ALL'
					THEN A.ysnSelected
				WHEN @strSelected = 'SELECTED'
					THEN 1
				WHEN @strSelected = 'UNSELECTED'
					THEN 0
				END
			)
	ORDER BY A.strName
END
