CREATE PROCEDURE [dbo].[uspLGGenerateDummyLoadDetail]
	@intLoadId INT,
	@dblQty NUMERIC(18,6),
	@intItemUOMId INT,
	@intEntityUserId INT,
	@intLoadDetailId INT OUTPUT,
    @intVendorEntityId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
    DECLARE @intItemId INT

    SELECT @intItemId = intItemId
    FROM tblICItemUOM IUOM
    WHERE IUOM.intItemUOMId = @intItemUOMId

    -- Insert Load Detail
    INSERT INTO tblLGLoadDetail (
        [intConcurrencyId]
        ,[intLoadId]
        ,[intItemId]
        ,[intItemUOMId]
        ,[dblQuantity]
        ,[dblGross]
        ,[dblTare]
        ,[dblNet]
        ,[dblDeliveredQuantity]
        ,[dblDeliveredGross]
        ,[dblDeliveredNet]
        ,[dblDeliveredTare]
        ,[intWeightItemUOMId]
        ,[intVendorEntityId]
    )
    SELECT
        [intConcurrencyId]					= 1
        ,[intLoadId]						= @intLoadId
        ,[intItemId]						= @intItemId
        ,[intItemUOMId]						= @intItemUOMId
        ,[dblQuantity]						= @dblQty
        ,[dblGross]							= @dblQty * W.dblWeightUnitQty
        ,[dblTare]							= 0
        ,[dblNet]							= @dblQty * W.dblWeightUnitQty
        ,[dblDeliveredQuantity]				= 0
        ,[dblDeliveredGross]				= 0
        ,[dblDeliveredNet]					= 0
        ,[dblDeliveredTare]					= 0
        ,[intWeightItemUOMId]				= WIUOM.intItemUOMId
        ,[intVendorEntityId]                = @intVendorEntityId
    FROM tblLGLoad L
    INNER JOIN tblICItemUOM WIUOM ON WIUOM.intItemId = @intItemId AND WIUOM.intUnitMeasureId = L.intWeightUnitMeasureId
    OUTER APPLY (
        SELECT [dblWeightUnitQty] = ISNULL(dbo.fnLGGetItemUnitConversion(@intItemId, @intItemUOMId, L.intWeightUnitMeasureId), 0)
    ) W
    WHERE L.intLoadId = @intLoadId

    SELECT @intLoadDetailId = SCOPE_IDENTITY()

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text
		@ErrorSeverity, -- Severity
		@ErrorState -- State
	);
END CATCH