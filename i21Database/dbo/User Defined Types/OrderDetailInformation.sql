CREATE TYPE [dbo].[OrderDetailInformation] AS TABLE (
	 [intId]							INT IDENTITY PRIMARY KEY CLUSTERED
	,[intOrderHeaderId]					INT
	,[intItemId]						INT
	,[dblQty]							NUMERIC(18, 6)
	,[intItemUOMId]						INT
	,[dblWeight]						NUMERIC(18, 6)
	,[intWeightUOMId]					INT
	,[dblWeightPerUnit]					NUMERIC(18, 6)
	,[intWeightPerUnitUOMId]			INT
	,[intLotId]							INT
	,[strLotAlias]						NVARCHAR(100)
	,[intUnitsPerLayer]					INT
	,[intLayersPerPallet]				INT
	,[intPreferenceId]					INT
	,[dtmProductionDate]				DATETIME
	,[intLineNo]						INT
	,[intSanitizationOrderDetailsId]	INT
	,[strLineItemNote]					NVARCHAR(MAX)
	,[strLastUpdateBy]					NVARCHAR(100))