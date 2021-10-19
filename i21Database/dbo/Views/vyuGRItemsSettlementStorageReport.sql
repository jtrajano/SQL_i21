CREATE VIEW [dbo].[vyuGRItemsSettlementStorageReport]
AS
SELECT B.* 
FROM tblGRStorageType ST 
INNER JOIN (
		SELECT
			ItemName		= A.strItemNo		
			,PivotColumn	= CONVERT(NVARCHAR,A.strStorageTypeDescription)
			,Amount			= CONVERT(NVARCHAR, CONVERT(DECIMAL(18,2), ISNULL(SUM(A.dblOpenBalance),0))) COLLATE Latin1_General_CI_AS
			,UnitMeasure	= UM.strUnitMeasure
			,intEntityId	= A.intEntityId
			,PivotColumnId = A.intStorageScheduleTypeId
		FROM (
				SELECT 
					CS.dblOpenBalance
					,CS.intEntityId
					,EM.strName
					,ST.strStorageTypeDescription
					,ST.intStorageScheduleTypeId
					,CS.intUnitMeasureId
					,CS.intItemId
					,IC.strItemNo
					,CS.intItemUOMId
				FROM tblGRCustomerStorage CS
				INNER JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				INNER JOIN tblEMEntity EM
					ON EM.intEntityId = CS.intEntityId
				INNER JOIN tblICItem IC
					ON IC.intItemId = CS.intItemId
				WHERE CS.dblOpenBalance > 0
			) A
		LEFT JOIN tblICUnitMeasure UM 
			ON A.intUnitMeasureId = UM.intUnitMeasureId
		GROUP BY A.intItemId
				, A.strItemNo
				, A.intEntityId
				, A.strStorageTypeDescription
				, A.intItemUOMId
				, A.intStorageScheduleTypeId
				, UM.strUnitMeasure
) B ON ST.intStorageScheduleTypeId = B.PivotColumnId