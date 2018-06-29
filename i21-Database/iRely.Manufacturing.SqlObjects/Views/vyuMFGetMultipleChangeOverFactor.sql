CREATE VIEW vyuMFGetMultipleChangeOverFactor
AS
SELECT SF.intChangeoverFactorId
	,SF.strName
	,MC.strCellName
	,MC.strDescription AS strCellDescription
	,SF.intLocationId
FROM dbo.tblMFScheduleChangeoverFactor SF
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SF.intManufacturingCellId
