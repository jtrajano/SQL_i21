CREATE FUNCTION [dbo].[fnGRDPRvsGrain]
(
	@intCommodityId INT
)
RETURNS @table TABLE
(
	strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strStorageType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblDPR DECIMAL(18,6)
	,dblGrainBalance_view DECIMAL(18,6)
	,DIFF_DPR_VS_GRAIN_VIEW DECIMAL(18,6)
)
AS
BEGIN
	DECLARE @tbl AS TABLE
	(
		intCommodityId INT
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strStorageType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,ysnDPOwnedType BIT
		,dblDPR DECIMAL(18,6)
		,dblGrainBalance_view DECIMAL (18,6)
		,dblGrainBalance_table DECIMAL (18,6)
		,intRec INT IDENTITY(1,1)
	)

	INSERT INTO @tbl
	SELECT DISTINCT 
		CS.intCommodityId
		,CS.intCompanyLocationId
		,CS.intStorageTypeId
		,CO.strCommodityCode
		,CL.strLocationName
		,ST.strStorageTypeDescription
		,ST.ysnDPOwnedType
		,0,0,0
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
	INNER JOIN tblICCommodity CO
		ON CO.intCommodityId = CS.intCommodityId		
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId
	WHERE CS.intCommodityId = @intCommodityId
		
	DECLARE @DPRQty DECIMAL(18,6)
	DECLARE @GrainQty_view DECIMAL(18,6)
	DECLARE @GrainQty_table DECIMAL(18,6)
	DECLARE @intCompanyLocationId INT
	DECLARE @intStorageTypeId INT
	DECLARE @strStorageType NVARCHAR(200)
	DECLARE @ysnDPOwnedType BIT
	DECLARE @intRec INT = 1
	DECLARE @rowCnt INT

	SELECT @rowCnt = COUNT(*) FROM @tbl

	WHILE @intRec <> 0
	BEGIN
		SET @intCommodityId = NULL
		SET @intCompanyLocationId = NULL
		SET @intStorageTypeId = NULL
		SET @strStorageType = NULL
		SET @ysnDPOwnedType = NULL
		SET @DPRQty = 0
		SET @GrainQty_view = 0
		SET @GrainQty_table = 0

		SELECT TOP 1 
			@intCommodityId			= intCommodityId
			,@intCompanyLocationId	= intCompanyLocationId
			,@intStorageTypeId		= intStorageTypeId
			,@strStorageType		= strStorageType
			,@ysnDPOwnedType		= ysnDPOwnedType
		FROM @tbl
		WHERE intRec = @intRec

		IF @ysnDPOwnedType = 0
		BEGIN
			SELECT @DPRQty = ISNULL(sum(ISNULL(dblTotal,0)),0)
			FROM dbo.fnRKGetBucketCustomerOwned(GETDATE(), @intCommodityId, NULL) t
			LEFT JOIN tblSCTicket SC 
				ON t.intTicketId = SC.intTicketId
			WHERE ISNULL(strStorageType, '') <> 'ITR' AND intTypeId IN (1, 3, 4, 5, 8, 9)
				AND t.intLocationId = @intCompanyLocationId
				AND t.strDistributionType = @strStorageType

			SELECT @GrainQty_view = SUM(dblOpenBalance)
			FROM vyuGRStorageSearchView CS
			WHERE intCommodityId = @intCommodityId
				AND intCompanyLocationId = @intCompanyLocationId
				AND intStorageTypeId = @intStorageTypeId
		END
		ELSE
		BEGIN
			SELECT @DPRQty = SUM(dblTotal) 
			FROM dbo.fnRKGetBucketDelayedPricing(GETDATE(),@intCommodityId,NULL) A
			WHERE A.intLocationId = @intCompanyLocationId

			SELECT @GrainQty_view = SUM(dblOpenBalance)
			FROM vyuGRStorageSearchView CS
			WHERE intCommodityId = @intCommodityId
				AND intCompanyLocationId = @intCompanyLocationId
				AND intStorageTypeId = @intStorageTypeId
		END
	
		UPDATE @tbl SET dblDPR = @DPRQty, dblGrainBalance_view = @GrainQty_view WHERE intRec = @intRec

		IF @intRec <> @rowCnt
		BEGIN
			SET @intRec = @intRec + 1
		END
		ELSE
		BEGIN
			SET @intRec = 0
		END	
	END

	INSERT INTO @table
	SELECT
		strLocationName
		,strStorageType
		,dblDPR
		,dblGrainBalance_view
		,DIFF_DPR_VS_GRAIN_VIEW = dblGrainBalance_view - dblDPR
	FROM @tbl

	RETURN;
END