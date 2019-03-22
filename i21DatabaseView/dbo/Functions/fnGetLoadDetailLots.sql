CREATE FUNCTION dbo.fnGetLoadDetailLots 
	(@intLoadDetailId INT)
RETURNS @returntable TABLE (
	 [intLoadId] INT
	,[intLotId] INT NULL
	,[strLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[intItemId] INT NULL
	,[intLoadDetailId] INT NULL
	,[dblWeight] NUMERIC(18, 6) NULL
	,[intWeightUOMId] INT
	)
AS
BEGIN
	INSERT @returntable
	SELECT L.intLoadId
		,LDL.intLotId
		,LOT.strLotNumber
		,LD.intItemId
		,LD.intLoadDetailId
		,LDL.dblNet
		,LDL.intWeightUOMId
	FROM tblLGLoad L
	LEFT JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	WHERE LD.intLoadDetailId = @intLoadDetailId

	RETURN
END
