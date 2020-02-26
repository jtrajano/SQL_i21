CREATE TYPE StagingCommanderFPHose AS TABLE
(
	[intRowCount] 								INT					NULL,
	[strFuelProdBaseNAXMLFuelGradeID] 			NVARCHAR(MAX)		NULL,
	[dblFuelInfoAmount]                         INT					NULL,
	[dblFuelInfoCount]                          NUMERIC(18,6)		NULL,
	[dblFuelInfoVolume]                         NUMERIC(18,6)		NULL

)
