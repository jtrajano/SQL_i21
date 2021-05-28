CREATE TABLE tblIPItemRouteDetailStage
(
	intItemRouteDetailStageId INT identity(1, 1),
	intItemRouteStageId INT NOT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strManufacturingCell NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strManufacturingGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intTrxSequenceNo BIGINT,
	intParentTrxSequenceNo BIGINT,

	CONSTRAINT [PK_tblIPItemRouteDetailStage] PRIMARY KEY (intItemRouteDetailStageId),
	CONSTRAINT [FK_tblIPItemRouteDetailStage_tblIPItemRouteStage] FOREIGN KEY (intItemRouteStageId) REFERENCES tblIPItemRouteStage(intItemRouteStageId) ON DELETE CASCADE
)
