CREATE TABLE tblIPItemRouteDetailArchive
(
	intItemRouteDetailStageId INT identity(1, 1),
	intItemRouteStageId INT NOT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strManufacturingCell NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strManufacturingGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intTrxSequenceNo BIGINT,
	intParentTrxSequenceNo BIGINT,

	CONSTRAINT [PK_tblIPItemRouteDetailArchive] PRIMARY KEY (intItemRouteDetailStageId),
	CONSTRAINT [FK_tblIPItemRouteDetailArchive_tblIPItemRouteArchive] FOREIGN KEY (intItemRouteStageId) REFERENCES tblIPItemRouteArchive(intItemRouteStageId) ON DELETE CASCADE
)
